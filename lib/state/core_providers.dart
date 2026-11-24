import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/dao/analysis_report_dao.dart';
import '../data/dao/balance_dao.dart';
import '../data/dao/bill_dao.dart';
import '../data/dao/category_dao.dart';
import '../data/dao/goal_dao.dart';
import '../data/dao/ledger_dao.dart';
import '../data/dao/user_dao.dart';
import '../data/database.dart';
import '../data/services/ai_client.dart';
import '../domain/services/balance_service.dart';
import '../domain/services/goal_accelerator.dart';
import '../domain/services/key_store.dart';
import '../domain/services/period_range_resolver.dart';

/// Database and stateless service wiring. Providers are the only place where
/// infrastructure objects are constructed.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final userDaoProvider = Provider<UserDao>((ref) => ref.watch(appDatabaseProvider).userDao);
final goalDaoProvider = Provider<GoalDao>((ref) => ref.watch(appDatabaseProvider).goalDao);
final ledgerDaoProvider =
    Provider<LedgerDao>((ref) => ref.watch(appDatabaseProvider).ledgerDao);
final billDaoProvider = Provider<BillDao>((ref) => ref.watch(appDatabaseProvider).billDao);
final categoryDaoProvider =
    Provider<CategoryDao>((ref) => ref.watch(appDatabaseProvider).categoryDao);
final balanceDaoProvider =
    Provider<BalanceDao>((ref) => ref.watch(appDatabaseProvider).balanceDao);
final analysisReportDaoProvider = Provider<AnalysisReportDao>(
  (ref) => ref.watch(appDatabaseProvider).analysisReportDao,
);

final balanceCacheProvider = Provider<BalanceCache>((ref) => BalanceCache());

final balanceServiceProvider = Provider<BalanceService>((ref) {
  return BalanceService(
    ref.watch(appDatabaseProvider),
    cache: ref.watch(balanceCacheProvider),
    dao: ref.watch(balanceDaoProvider),
  );
});

final periodRangeResolverProvider =
    Provider<PeriodRangeResolver>((ref) => const PeriodRangeResolver());
final goalAcceleratorProvider =
    Provider<GoalAccelerator>((ref) => const GoalAccelerator());

final aiKeyStoreProvider = Provider<AiKeyStore>((ref) => AiKeyStore());
final aiClientProvider = Provider<AiClient>(
  (ref) => AiClient(keyStore: ref.watch(aiKeyStoreProvider)),
);
