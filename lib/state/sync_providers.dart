import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/sync/sync_service.dart';
import '../domain/models/user.dart' as model;
import '../domain/services/token_store.dart';
import 'auth_providers.dart';
import 'core_providers.dart';
import 'service_providers.dart';

export '../data/sync/sync_service.dart' show SyncPhase, SyncStatus;

/// 同步状态流（UI 轻量标识：同步中/已同步/离线待同步 N 条，PRD R5）。
final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  return ref.watch(syncServiceProvider).statusStream;
});

/// 待同步行数（设置页展示）。
final pendingSyncCountProvider = FutureProvider<int>((ref) {
  return ref.watch(syncServiceProvider).pendingCount();
});

/// 同步触发编排（T4）：
/// 1. 登录态变化 → 会话可用性 + 云端 uid 注入，登录成功立即拉取；
/// 2. 本地写操作 → Drift tableUpdates 监听，5s 防抖推送（R1）；
/// 3. 恢复联网 → connectivity 监听触发增量同步（US-2：60s 内自动上传）；
/// 4. 前台定时增量。
///
/// main.dart 启动时 `ref.read(syncOrchestratorProvider)` 激活。
/// 登录态变化会重建本 provider（watch currentUserProvider），
/// 监听器随之重建，onDispose 保证不泄漏。
final syncOrchestratorProvider = Provider<void>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  final tokenStore = ref.watch(tokenStoreProvider);
  final db = ref.watch(appDatabaseProvider);

  // 1) 登录态 → 会话/云端 uid/首拉（同步登录态进 SyncService）。
  //
  // 注意：这里必须用 ref.listen 而不是 ref.watch。本 provider 只被 main()
  // 用 ref.read 激活一次，没有任何 Widget 在 watch 它；若用 watch，
  // 登录态变化只会把它标记为 dirty 而不会被重建，_applySession 永不重跑，
  // 表现为「登录成功但一条数据都同步不下来」。
  ref.listen<model.User?>(currentUserProvider, (previous, next) {
    unawaited(_applySession(syncService, tokenStore, next));
  });
  unawaited(_applySession(syncService, tokenStore, ref.read(currentUserProvider)));

  final subscriptions = <StreamSubscription<void>>[];

  // 2) 本地写操作 → 防抖推送（只监听 7 张同步业务表，
  //    避免监听 users/sync_states 造成「同步→写水位→再触发」死循环）
  subscriptions.add(
    db
        .tableUpdates(
          TableUpdateQuery.allOf(<TableUpdateQuery>[
            TableUpdateQuery.onTable(db.bills),
            TableUpdateQuery.onTable(db.ledgers),
            TableUpdateQuery.onTable(db.categories),
            TableUpdateQuery.onTable(db.savingsGoals),
            TableUpdateQuery.onTable(db.goalLedgerBindings),
            TableUpdateQuery.onTable(db.goalMilestones),
            TableUpdateQuery.onTable(db.aiAnalysisReports),
          ]),
        )
        .listen((_) => syncService.notifyLocalChange()),
  );

  // 3) 恢复联网 → 自动同步
  subscriptions.add(
    Connectivity().onConnectivityChanged.listen((results) {
      final connected = results.any((result) =>
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.ethernet);
      if (connected && syncService.hasSession) {
        syncService.syncNow();
      }
    }),
  );

  ref.onDispose(() {
    for (final subscription in subscriptions) {
      subscription.cancel();
    }
    syncService.stopPeriodic();
  });
});

/// 根据当前用户计算云端会话并注入 SyncService；登录后立即增量拉取
/// （水位 0 时自然全量首拉）。
Future<void> _applySession(
  SyncService syncService,
  TokenStore tokenStore,
  model.User? user,
) async {
  final cloudUid = (user != null && user.loginType == 'email')
      ? await tokenStore.readCloudUid()
      : null;
  final hasSession =
      cloudUid != null && cloudUid.isNotEmpty && user?.id == cloudUid;
  syncService.setSessionAvailable(hasSession);
  syncService.setCloudUid(hasSession ? cloudUid : null);
  if (hasSession) {
    syncService.startPeriodic();
    syncService.syncNow();
  } else {
    syncService.stopPeriodic();
  }
}
