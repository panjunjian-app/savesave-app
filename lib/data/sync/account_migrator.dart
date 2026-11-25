import '../database.dart';
import 'sync_dao.dart';
import 'sync_service.dart';

/// 迁移结果摘要（设置页/引导页展示）。
class MigrationResult {
  const MigrationResult({
    required this.success,
    required this.uploadedRows,
    this.message,
  });

  final bool success;
  final int uploadedRows;
  final String? message;
}

/// v1 本机账号/游客数据「升级上云」迁移（架构 §6.4，PRD C8）。
///
/// 三步可重试（红线：迁移全程本地只写不改删）：
/// 1. 重写归属：单事务把 user_id 统一改写为云端 uid、补齐 updated_at；
/// 2. 全量上传：pushAll 分批推送（服务端盖章 user_id，逐行幂等 upsert）；
/// 3. 校验：确认不再有非云端归属的行；任一步失败不删任何本地数据，可直接重试。
/// 成功后标记 migration_done，此后进入常规增量同步。
class AccountMigrator {
  AccountMigrator({
    required this.db,
    required this.syncService,
    required this.cloudUidResolver,
    required this.migrationDoneReader,
    required this.markMigrationDone,
    SyncDao? syncDao,
  }) : syncDao = syncDao ?? SyncDao(db);

  /// 本地 Drift 数据库。
  final AppDatabase db;

  /// 同步引擎（pushAll 全量上传用）。
  final SyncService syncService;

  /// 同步数据访问层（归属重写与校验）。
  final SyncDao syncDao;

  /// 当前云端 uid（null = 未登录云端）。
  final Future<String?> Function() cloudUidResolver;

  /// 是否已完成迁移（C8 一次性标记）。
  final Future<bool> Function() migrationDoneReader;

  /// 标记迁移完成。
  final Future<void> Function() markMigrationDone;

  /// 是否存在待迁移数据：已登录云端且本地仍有不属于云端 uid 的行。
  Future<bool> needsMigration() async {
    final cloudUid = await cloudUidResolver();
    if (cloudUid == null || cloudUid.isEmpty) {
      return false;
    }
    if (await migrationDoneReader()) {
      return false;
    }
    // 本地仍有不属于云端 uid 的行 → 待迁移。
    return await syncDao.countForeignRows(cloudUid) > 0;
  }

  /// 执行迁移（可重试：幂等 by id upsert，重写归属同样幂等）。
  Future<MigrationResult> migrate() async {
    final cloudUid = await cloudUidResolver();
    if (cloudUid == null || cloudUid.isEmpty) {
      return const MigrationResult(
        success: false,
        uploadedRows: 0,
        message: '尚未登录云端账号',
      );
    }

    // 步骤 1：归属重写（单事务，只写不删）
    await syncDao.rewriteOwnership(cloudUid);

    // 步骤 2：全量上传（服务端逐行幂等 upsert）
    final rowsBefore = await _countLocalRows();
    await syncService.pushAll();

    // 步骤 3：校验归属完整（失败不删本地数据，可重试）
    final foreign = await syncDao.countForeignRows(cloudUid);
    if (foreign > 0) {
      return MigrationResult(
        success: false,
        uploadedRows: rowsBefore,
        message: '仍有 $foreign 行未完成归属迁移，请重试',
      );
    }

    await markMigrationDone();
    return MigrationResult(success: true, uploadedRows: rowsBefore);
  }

  /// 本地业务行总数，迁移完成后用于展示规模。
  Future<int> _countLocalRows() async {
    const tables = <String>[
      'ledgers',
      'bills',
      'categories',
      'savings_goals',
      'goal_ledger_bindings',
      'goal_milestones',
      'ai_analysis_reports',
    ];
    var total = 0;
    for (final table in tables) {
      final rows = await db
          .customSelect('SELECT COUNT(*) AS c FROM $table')
          .get();
      total += rows.first.read<int>('c');
    }
    return total;
  }
}
