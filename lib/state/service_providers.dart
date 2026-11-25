import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/sync/account_migrator.dart';
import '../data/sync/sync_service.dart';
import '../domain/models/category.dart';
import '../domain/services/auth_service.dart';
import '../domain/services/bill_service.dart';
import '../domain/services/goal_service.dart';
import '../domain/services/ledger_service.dart';
import '../domain/services/period_range_resolver.dart';
import '../domain/services/statistics_service.dart';
import '../domain/services/update_service.dart';
import 'core_providers.dart';

/// 云端认证服务（注册/登录/登出/会话恢复，v3 云端化）。
final authServiceProvider = Provider<AuthService>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return AuthService(
    database,
    remote: ref.watch(apiClientProvider),
    tokenStore: ref.watch(tokenStoreProvider),
    legacyHashChecker: LocalLegacyHashChecker(database).call,
  );
});

/// 同步引擎（水位 pull + 脏数据 push + LWW + 离线队列）。
final syncServiceProvider = Provider<SyncService>((ref) {
  final service = SyncService(
    db: ref.watch(appDatabaseProvider),
    api: ref.watch(apiClientProvider),
    syncDao: ref.watch(syncDaoProvider),
  );
  ref.onDispose(service.dispose);
  return service;
});

/// 本机账号「升级上云」迁移器（C8，一次性事务、可重试）。
final accountMigratorProvider = Provider<AccountMigrator>((ref) {
  final tokenStore = ref.watch(tokenStoreProvider);
  return AccountMigrator(
    db: ref.watch(appDatabaseProvider),
    syncService: ref.watch(syncServiceProvider),
    syncDao: ref.watch(syncDaoProvider),
    cloudUidResolver: () => tokenStore.readCloudUid(),
    migrationDoneReader: () => tokenStore.isMigrationDone(),
    markMigrationDone: () => tokenStore.setMigrationDone(),
  );
});

final goalServiceProvider = Provider<GoalService>((ref) {
  return GoalService(
    ref.watch(appDatabaseProvider),
    ref.watch(balanceServiceProvider),
  );
});

final billServiceProvider = Provider<BillService>((ref) {
  return BillService(
    ref.watch(appDatabaseProvider),
    ref.watch(balanceServiceProvider),
  );
});

final ledgerServiceProvider = Provider<LedgerService>((ref) {
  return LedgerService(ref.watch(appDatabaseProvider));
});

final statisticsServiceProvider = Provider<StatisticsService>((ref) {
  return StatisticsService(
    ref.watch(appDatabaseProvider),
    ref.watch(periodRangeResolverProvider),
  );
});

final categoriesProvider = StreamProvider<List<Category>>((ref) {
  return ref.watch(categoryDaoProvider).watchAll();
});

final statsProvider = FutureProvider.family<
    StatsSnapshot,
    ({String ledgerKey, PeriodType periodType, int offset})>((ref, key) {
  return ref.watch(statisticsServiceProvider).build(
        ledgerKey: key.ledgerKey,
        periodType: key.periodType,
        offset: key.offset,
      );
});

/// 应用内更新（Android 专属；Web 刷新即最新）。
final updateServiceProvider = Provider<UpdateService>((ref) {
  final service = UpdateService();
  ref.onDispose(service.dispose);
  return service;
});
