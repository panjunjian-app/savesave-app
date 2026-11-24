import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/category.dart';
import '../domain/services/auth_service.dart';
import '../domain/services/bill_service.dart';
import '../domain/services/goal_service.dart';
import '../domain/services/ledger_service.dart';
import '../domain/services/period_range_resolver.dart';
import '../domain/services/statistics_service.dart';
import 'core_providers.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(appDatabaseProvider));
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
