import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';

import '../../data/database.dart';
import '../../data/dao/balance_dao.dart';

/// Authoritative net balance of a goal, measured in integer cents.
class BalanceBreakdown {
  const BalanceBreakdown({
    required this.monthIncomeCents,
    required this.monthExpenseCents,
    required this.monthNetCents,
    required this.cumulativeNetCents,
  });

  final int monthIncomeCents;
  final int monthExpenseCents;
  final int monthNetCents;
  final int cumulativeNetCents;
}

/// Progress of one goal. [balanceCents] keeps the real (possibly negative)
/// value while [ratio]/[displayPercent] are clamped for display.
class GoalProgress {
  const GoalProgress({
    required this.balanceCents,
    required this.ratio,
    required this.displayPercent,
    required this.surplusCents,
    this.hint,
    required this.isNegative,
  });

  final int balanceCents;
  final Decimal ratio;
  final int displayPercent;
  final int surplusCents;
  final String? hint;
  final bool isNegative;

  static GoalProgress get empty => GoalProgress(
    balanceCents: 0,
    ratio: Decimal.zero,
    displayPercent: 0,
    surplusCents: 0,
    hint: '请先绑定账本',
    isNegative: false,
  );
}

/// A milestone that was reached for the first time by the current calculation.
class MilestoneReached {
  const MilestoneReached({
    required this.thresholdPct,
    required this.firstReachedDate,
    required this.newlyReached,
  });

  final int thresholdPct;
  final String firstReachedDate;
  final bool newlyReached;
}

class _CacheEntry<T> {
  const _CacheEntry(this.value, this.dependencies, this.versionSnapshot);

  final T value;
  final Set<String> dependencies;

  /// Per-ledger revision numbers captured at the moment this entry was written.
  /// Freshness is decided by comparing this snapshot with current revisions;
  /// storing no snapshot (or snapshotting at read time) would make every entry
  /// look permanently fresh and defeat invalidation.
  final Map<String, int> versionSnapshot;
}

/// In-memory cache with per-ledger revision numbers. Correctness never depends
/// on the cache: a cold start simply recomputes everything from SQLite.
class BalanceCache {
  final Map<String, int> _revision = <String, int>{};
  final Map<String, _CacheEntry<int>> _net = <String, _CacheEntry<int>>{};
  final Map<String, _CacheEntry<GoalProgress>> _progress =
      <String, _CacheEntry<GoalProgress>>{};

  static String keyOf(Set<String> ledgerIds) {
    final sorted = ledgerIds.toList()..sort();
    return sorted.join(',');
  }

  int _versionOf(String ledgerId) => _revision[ledgerId] ?? 0;

  /// Fresh only if none of the dependency revisions changed since the entry
  /// was written. [snapshot] is the version captured at write time.
  bool _isFresh(Map<String, int> snapshot) {
    for (final entry in snapshot.entries) {
      if (_versionOf(entry.key) != entry.value) {
        return false;
      }
    }
    return true;
  }

  Map<String, int> _snapshot(Set<String> dependencies) => <String, int>{
        for (final ledgerId in dependencies) ledgerId: _versionOf(ledgerId),
      };

  int? getNet(Set<String> ledgerIds) {
    final entry = _net[keyOf(ledgerIds)];
    if (entry == null) {
      return null;
    }
    return _isFresh(entry.versionSnapshot) ? entry.value : null;
  }

  void putNet(Set<String> ledgerIds, int net) {
    final dependencies = ledgerIds.toSet();
    _net[keyOf(ledgerIds)] = _CacheEntry<int>(
      net,
      dependencies,
      _snapshot(dependencies),
    );
  }

  GoalProgress? getProgress(String goalId, Set<String> ledgerIds) {
    final entry = _progress[goalId];
    if (entry == null) {
      return null;
    }
    return _isFresh(entry.versionSnapshot) ? entry.value : null;
  }

  void putProgress(String goalId, Set<String> ledgerIds, GoalProgress progress) {
    final dependencies = ledgerIds.toSet();
    _progress[goalId] = _CacheEntry<GoalProgress>(
      progress,
      dependencies,
      _snapshot(dependencies),
    );
  }

  void bumpLedger(Set<String> ledgerIds) {
    for (final ledgerId in ledgerIds) {
      _revision[ledgerId] = _versionOf(ledgerId) + 1;
    }
  }

  void clear() {
    _revision.clear();
    _net.clear();
    _progress.clear();
  }
}

/// Computes net balances, goal progress and milestones from bound ledgers.
class BalanceService {
  BalanceService(
    this._db, {
    BalanceCache? cache,
    BalanceDao? dao,
  })  : _cache = cache ?? BalanceCache(),
        _dao = dao ?? BalanceDao(_db);

  static const List<int> milestoneThresholds = <int>[25, 50, 75, 100];

  /// Fractional digits kept when a balance/target rational is non-terminating
  /// (e.g. 1/3). Ten digits far exceed the precision needed for a 0-100% ring.
  static const int _ratioPrecision = 10;

  final AppDatabase _db;
  final BalanceCache _cache;
  final BalanceDao _dao;

  /// Sum of (income - expense) across the de-duplicated bound ledgers.
  Future<int> netBalanceOf(Set<String> ledgerIds) async {
    final unique = ledgerIds.toSet();
    if (unique.isEmpty) {
      return 0;
    }
    final cached = _cache.getNet(unique);
    if (cached != null) {
      return cached;
    }
    final rows = await _dao.sumByLedger(unique);
    final net = rows.fold<int>(0, (sum, row) => sum + row.incomeCents - row.expenseCents);
    _cache.putNet(unique, net);
    return net;
  }

  Future<Map<String, int>> netBalancesByLedger(Set<String> ledgerIds) async {
    final rows = await _dao.sumByLedger(ledgerIds.toSet());
    return <String, int>{
      for (final row in rows) row.ledgerId: row.incomeCents - row.expenseCents,
    };
  }

  Future<BalanceBreakdown> breakdownOf(Set<String> ledgerIds) async {
    final now = DateTime.now();
    final from = DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month, 1));
    final to = DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month + 1, 0));
    final rows = await _dao.sumByLedger(ledgerIds.toSet());
    final monthRows = await _dao.sumByLedgerRange(
      ledgerIds: ledgerIds.toSet(),
      from: from,
      to: to,
    );
    final monthIncome = monthRows.fold<int>(0, (sum, row) => sum + row.incomeCents);
    final monthExpense = monthRows.fold<int>(0, (sum, row) => sum + row.expenseCents);
    final cumulative = rows.fold<int>(
      0,
      (sum, row) => sum + row.incomeCents - row.expenseCents,
    );
    return BalanceBreakdown(
      monthIncomeCents: monthIncome,
      monthExpenseCents: monthExpense,
      monthNetCents: monthIncome - monthExpense,
      cumulativeNetCents: cumulative,
    );
  }

  Future<GoalProgress> progressOf(String goalId) async {
    final goal = await _db.goalDao.findById(goalId);
    if (goal == null) {
      return GoalProgress.empty;
    }
    final boundLedgers = await _db.goalDao.boundLedgerIds(goalId);
    if (boundLedgers.isEmpty) {
      return GoalProgress.empty;
    }
    final cached = _cache.getProgress(goalId, boundLedgers);
    if (cached != null) {
      return cached;
    }

    final balance = await netBalanceOf(boundLedgers);
    final target = goal.targetAmountCents;
    if (target <= 0) {
      return GoalProgress.empty;
    }

    final isNegative = balance <= 0;
    // A rational such as 1/3 has no finite decimal representation. Converting
    // it with plain toDecimal() trips an assert in decimal 2.x. Scale the
    // infinite-precision case to a bounded number of fractional digits instead
    // (the stored ratio is display-only; authoritative math stays in cents).
    final ratio = isNegative
        ? Decimal.zero
        : (Decimal.fromInt(balance) / Decimal.fromInt(target)).toDecimal(
            scaleOnInfinitePrecision: _ratioPrecision,
          );
    final percentValue = ratio * Decimal.fromInt(100);
    final displayPercent = percentValue >= Decimal.fromInt(100)
        ? 100
        : percentValue.round().toBigInt().toInt();
    final progress = GoalProgress(
      balanceCents: balance,
      ratio: ratio,
      displayPercent: displayPercent,
      surplusCents: balance > target ? balance - target : 0,
      isNegative: isNegative,
      hint: isNegative ? '当前绑定账本结余为负或为零，暂无累计进度' : null,
    );
    _cache.putProgress(goalId, boundLedgers, progress);
    return progress;
  }

  Future<Map<String, GoalProgress>> progressOfGoals(Set<String> goalIds) async {
    final result = <String, GoalProgress>{};
    for (final goalId in goalIds) {
      result[goalId] = await progressOf(goalId);
    }
    return result;
  }

  /// First-reach-wins milestone check: regression never removes a record.
  Future<List<MilestoneReached>> checkMilestones(
    String goalId,
    GoalProgress progress,
  ) async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final reached = <MilestoneReached>[];
    for (final threshold in milestoneThresholds) {
      if (progress.displayPercent < threshold) {
        continue;
      }
      final isNew = await _db.goalDao.recordMilestoneOnce(
        goalId: goalId,
        thresholdPct: threshold,
        firstReachedDate: today,
      );
      reached.add(
        MilestoneReached(
          thresholdPct: threshold,
          firstReachedDate: today,
          newlyReached: isNew,
        ),
      );
    }
    return reached;
  }

  /// Called after any bill / binding / ledger change.
  void invalidate(Set<String> ledgerIds) => _cache.bumpLedger(ledgerIds.toSet());
}
