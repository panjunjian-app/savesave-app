import 'dart:async';

import '../../core/api_client.dart';
import '../../core/api_config.dart';
import '../database.dart';
import 'sync_dao.dart';
import 'sync_models.dart';

/// 同步状态机阶段（架构 §6.2）：idle → pulling → pushing → idle / offline / error。
enum SyncPhase { idle, pulling, pushing, offline, error }

/// 对外广播的同步状态（UI 轻量标识，PRD R5）。
class SyncStatus {
  const SyncStatus({
    required this.phase,
    this.pendingCount = 0,
    this.lastSyncAt,
    this.errorMessage,
  });

  final SyncPhase phase;

  /// 待上传（脏）行数：离线待同步 N 条的 N。
  final int pendingCount;

  /// 最近一次成功同步的时间（本地时刻）。
  final DateTime? lastSyncAt;

  /// 最近一次失败的中文原因（设置页展示）。
  final String? errorMessage;

  SyncStatus copyWith({
    SyncPhase? phase,
    int? pendingCount,
    DateTime? lastSyncAt,
    String? errorMessage,
    bool clearError = false,
    bool clearLastSyncAt = false,
  }) {
    return SyncStatus(
      phase: phase ?? this.phase,
      pendingCount: pendingCount ?? this.pendingCount,
      lastSyncAt: clearLastSyncAt ? null : (lastSyncAt ?? this.lastSyncAt),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// 同步引擎（架构 §6.2）。
///
/// 流程：bootstrap（启动/恢复联网/手动）→ pull 增量（服务端 synced_at 水位）
/// → LWW 落库 → 扫描脏数据 → push 分批上传 → 清水位；失败指数退避
/// （15s→2m→10m，上限），脏数据始终保留本地等待重试。
///
/// 触发源（R1）：
/// - 登录后首拉（fullFirstPull=true 时从 0 水位拉全量）；
/// - 本地写操作（[notifyLocalChange] 5s 防抖，由 tableUpdates 驱动）；
/// - 定时增量（[startPeriodic]）；
/// - 恢复联网（providers 监听 connectivity 后调用 [syncNow]）；
/// - 手动「立即同步」。
class SyncService {
  SyncService({
    required this.db,
    required this.api,
    SyncDao? syncDao,
  }) : syncDao = syncDao ?? SyncDao(db);

  static const String _globalKey = '__global__';

  /// 本地 Drift 数据库（运行时数据源）。
  final AppDatabase db;

  /// 同步通道（pull/push），测试可注入 mock。
  final SyncApi api;

  /// 同步数据访问层（水位/脏扫描/LWW 落库）。
  final SyncDao syncDao;

  final StreamController<SyncStatus> _statusController =
      StreamController<SyncStatus>.broadcast();
  SyncStatus _status = const SyncStatus(phase: SyncPhase.idle);

  /// 并发保护：同一时刻只允许一个同步循环（单飞）。
  Future<void>? _running;

  Timer? _periodicTimer;
  Timer? _debounceTimer;
  Timer? _retryTimer;
  int _backoffStep = 0;
  bool _hasSession = false;

  /// UI 订阅的同步状态流。
  Stream<SyncStatus> get statusStream => _statusController.stream;

  SyncStatus get status => _status;

  /// 云端会话是否可用（登录成功后由 providers 置 true）。
  bool get hasSession => _hasSession;

  // ============ 状态广播 ============

  void _emit(SyncStatus next) {
    _status = next;
    if (!_statusController.isClosed) {
      _statusController.add(next);
    }
  }

  /// 登录/登出后由 providers 更新会话可用性。
  void setSessionAvailable(bool available) {
    _hasSession = available;
    if (!available) {
      _periodicTimer?.cancel();
      _retryTimer?.cancel();
      _emit(const SyncStatus(phase: SyncPhase.offline));
    }
  }

  // ============ 触发入口 ============

  /// 启动/恢复联网/手动下拉刷新统一入口。
  /// [fullFirstPull]：登录后首拉，从水位 0 全量拉取（架构 §4.6）。
  Future<void> syncNow({bool fullFirstPull = false}) {
    if (_running != null) {
      return _running!;
    }
    final task = _runSync(fullFirstPull: fullFirstPull)
        .whenComplete(() => _running = null);
    _running = task;
    return task;
  }

  /// 本地写操作后的推送触发（5s 防抖合并，R1）。
  void notifyLocalChange() {
    if (!_hasSession) {
      return;
    }
    _debounceTimer?.cancel();
    _debounceTimer = Timer(ApiConfig.pushDebounce, () {
      syncNow();
    });
  }

  /// 前台定时增量同步（App 恢复前台时由 main/providers 调用）。
  void startPeriodic() {
    if (!_hasSession) {
      return;
    }
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(ApiConfig.periodicSyncInterval, (_) {
      syncNow();
    });
  }

  void stopPeriodic() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
  }

  void dispose() {
    _periodicTimer?.cancel();
    _debounceTimer?.cancel();
    _retryTimer?.cancel();
    _statusController.close();
  }

  // ============ 同步主循环 ============

  Future<void> _runSync({required bool fullFirstPull}) async {
    if (!_hasSession) {
      _emit(const SyncStatus(phase: SyncPhase.offline));
      return;
    }
    _retryTimer?.cancel();
    try {
      _emit(_status.copyWith(phase: SyncPhase.pulling, clearError: true));
      await _pull(full: fullFirstPull);
      _emit(_status.copyWith(phase: SyncPhase.pushing));
      await _push();
      _backoffStep = 0;
      _emit(_status.copyWith(
        phase: SyncPhase.idle,
        lastSyncAt: DateTime.now(),
        clearError: true,
      ));
    } on SessionExpiredException {
      // 会话彻底失效：置离线，providers 据此踢回登录页。
      _hasSession = false;
      await syncDao.saveLastError('登录已失效，请重新登录');
      _emit(const SyncStatus(
        phase: SyncPhase.offline,
        errorMessage: '登录已失效，请重新登录',
      ));
    } on ApiFailure catch (error) {
      await _scheduleRetry(error.message);
    } on NetworkUnavailableException {
      // 云端不可达：降级为本地模式（S10），脏数据保留。
      _emit(_status.copyWith(
        phase: SyncPhase.offline,
        errorMessage: '网络不可用，数据已保存在本机',
      ));
    } catch (error) {
      await _scheduleRetry('同步失败：$error');
    }
  }

  Future<void> _scheduleRetry(String message) async {
    final backoff = ApiConfig.pushRetryBackoff[
        _backoffStep.clamp(0, ApiConfig.pushRetryBackoff.length - 1)];
    _backoffStep = (_backoffStep + 1).clamp(0, ApiConfig.pushRetryBackoff.length - 1);
    await syncDao.saveLastError(message);
    _emit(_status.copyWith(
      phase: SyncPhase.error,
      errorMessage: message,
    ));
    _retryTimer?.cancel();
    _retryTimer = Timer(backoff, () => syncNow());
  }

  /// 增量拉取 + LWW 落库（架构 §4.6 / §6.2）。
  Future<void> _pull({required bool full}) async {
    var since = full ? 0 : (await syncDao.readWatermarks()).lastPullSyncedAt;
    final cloudUid = _cloudUidOverride ?? '';
    var hasMore = true;
    while (hasMore) {
      final response = await api.pull(since: since, limit: ApiConfig.pullPageSize);
      hasMore = response.hasMore;
      var maxSyncedAt = 0;
      await db.transaction(() async {
        for (final entry in response.changes.entries) {
          final rows = entry.value;
          for (final row in rows) {
            final rowSyncedAt = (row['syncedAt'] as num?)?.toInt() ?? 0;
            if (rowSyncedAt > maxSyncedAt) {
              maxSyncedAt = rowSyncedAt;
            }
          }
          await syncDao.applyServerRows(entry.key, rows, cloudUid);
        }
        // 水位：分页中用本批最大 synced_at 续拉；结束后用 serverTime 兜底
        // （服务端时钟背书，规避客户端时钟漂移，架构 §1.4）。
        final nextWatermark =
            hasMore && maxSyncedAt > 0 ? maxSyncedAt : response.serverTime;
        if (nextWatermark > since) {
          await syncDao.savePullWatermark(nextWatermark);
          since = nextWatermark;
        }
      });
    }
  }

  /// 脏数据扫描 + 分批推送 + 冲突回滚（架构 §4.7 / §6.2）。
  Future<void> _push() async {
    // 水位先于扫描定格：推送期间的新写入（updatedAt > scanStartedAt）
    // 留待下一轮，绝不漏推。
    final scanStartedAt = isoNowMs();
    final lastPushAt = (await syncDao.readWatermarks()).lastPushAt;
    final dirty = await syncDao.collectDirtyRows(lastPushAt);
    final pendingCount =
        dirty.values.fold<int>(0, (sum, rows) => sum + rows.length);
    _emit(_status.copyWith(pendingCount: pendingCount));

    if (pendingCount == 0) {
      return;
    }

    final conflicts = <String>[];
    // 分批：每批 ≤500 行 / ≤2MB（架构 §9.8）。
    for (final entry in dirty.entries) {
      final rows = entry.value;
      for (var start = 0; start < rows.length; start += ApiConfig.syncBatchRows) {
        final end = (start + ApiConfig.syncBatchRows).clamp(0, rows.length);
        final batch = <String, List<Map<String, dynamic>>>{
          entry.key: rows.sublist(start, end),
        };
        final response = await api.push(batch);
        conflicts.addAll(response.conflicts);
      }
    }

    await syncDao.savePushWatermark(scanStartedAt);

    // 服务端拒绝（LWW 落败）的行：回滚为云端版本 —— 全量重拉一次
    // （按 id 幂等，服务端行较旧则本地保留，符合 LWW 语义）。
    if (conflicts.isNotEmpty) {
      await _pull(full: true);
    }
    _emit(_status.copyWith(pendingCount: 0));
  }

  /// 待同步行数快照（UI 离线徽标用，避免整轮同步）。
  Future<int> pendingCount() async {
    final watermarks = await syncDao.readWatermarks();
    return syncDao.countDirty(watermarks.lastPushAt);
  }

  /// 当前云端 uid（由 providers 注入，避免 SyncService 直接依赖 TokenStore）。
  String? _cloudUidOverride;

  /// 由 providers 注入当前云端 uid。
  void setCloudUid(String? uid) {
    _cloudUidOverride = uid;
  }

  /// 全量推送（账号迁移用，架构 §6.4 pushAll）：清零推送水位后整体上传。
  Future<void> pushAll() async {
    if (!_hasSession) {
      return;
    }
    await syncDao.savePushWatermark('');
    _emit(_status.copyWith(phase: SyncPhase.pushing));
    final scanStartedAt = isoNowMs();
    final dirty = await syncDao.collectDirtyRows('');
    for (final entry in dirty.entries) {
      for (var start = 0; start < entry.value.length; start += ApiConfig.syncBatchRows) {
        final end = (start + ApiConfig.syncBatchRows).clamp(0, entry.value.length);
        await api.push(<String, List<Map<String, dynamic>>>{
          entry.key: entry.value.sublist(start, end),
        });
      }
    }
    await syncDao.savePushWatermark(scanStartedAt);
    _emit(_status.copyWith(phase: SyncPhase.idle, lastSyncAt: DateTime.now()));
  }

  // 供测试/内部使用的水位常量。
  static String get globalStateKey => _globalKey;
}
