import 'package:drift/drift.dart';

import '../database.dart';
import '../tables.dart';
import '../../domain/models/savings_goal.dart' as model;

part 'goal_dao.g.dart';

/// Data access for goals, ledger bindings and milestones.
@DriftAccessor(tables: [SavingsGoals, GoalLedgerBindings, GoalMilestones])
class GoalDao extends DatabaseAccessor<AppDatabase> with _$GoalDaoMixin {
  GoalDao(super.attachedDatabase);

  Stream<List<model.SavingsGoal>> watchAll() {
    final query = select(savingsGoals)
      ..orderBy([(row) => OrderingTerm.asc(row.createdAt)]);
    return query
        .watch()
        .map((rows) => rows.map(_mapGoal).toList(growable: false));
  }

  Stream<List<model.SavingsGoal>> watchByUser(String userId) {
    return (select(savingsGoals)..where((row) => row.userId.equals(userId)))
        .watch()
        .map((rows) => rows.map(_mapGoal).toList(growable: false));
  }

  Stream<model.SavingsGoal?> watchById(String id) {
    return (select(savingsGoals)..where((row) => row.id.equals(id)))
        .watch()
        .map((rows) => rows.isEmpty ? null : _mapGoal(rows.first));
  }

  Future<model.SavingsGoal?> findById(String id) async {
    final rows = await (select(savingsGoals)..where((row) => row.id.equals(id))).get();
    return rows.isEmpty ? null : _mapGoal(rows.first);
  }

  Future<void> save(model.SavingsGoal goal) async {
    await into(savingsGoals).insert(
          SavingsGoalsCompanion.insert(
            id: goal.id,
            userId: goal.userId,
            name: goal.name,
            targetAmountCents: goal.targetAmountCents,
            deadline: Value(goal.deadline),
            icon: Value(goal.icon),
            themeColor: Value(goal.themeColor),
            note: Value(goal.note),
            status: Value(goal.status),
            createdAt: goal.createdAt.toUtc().toIso8601String(),
            updatedAt: goal.updatedAt.toUtc().toIso8601String(),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  Future<void> updateTarget(String goalId, int targetAmountCents) async {
    await (update(savingsGoals)..where((row) => row.id.equals(goalId))).write(
      SavingsGoalsCompanion(
        targetAmountCents: Value(targetAmountCents),
        updatedAt: Value(DateTime.now().toUtc().toIso8601String()),
      ),
    );
  }

  Future<void> updateStatus(String goalId, String status) async {
    await (update(savingsGoals)..where((row) => row.id.equals(goalId))).write(
      SavingsGoalsCompanion(
        status: Value(status),
        updatedAt: Value(DateTime.now().toUtc().toIso8601String()),
      ),
    );
  }

  Future<int> deleteAll() => delete(savingsGoals).go();

  Future<void> remove(String goalId) async {
    await (delete(goalLedgerBindings)..where((row) => row.goalId.equals(goalId))).go();
    await (delete(goalMilestones)..where((row) => row.goalId.equals(goalId))).go();
    await (delete(savingsGoals)..where((row) => row.id.equals(goalId))).go();
  }

  Stream<Set<String>> watchBoundLedgerIds(String goalId) {
    return (select(goalLedgerBindings)
          ..where((row) => row.goalId.equals(goalId)))
        .watch()
        .map((rows) => rows.map((row) => row.ledgerId).toSet());
  }

  Future<Set<String>> boundLedgerIds(String goalId) async {
    final rows =
        await (select(goalLedgerBindings)..where((row) => row.goalId.equals(goalId))).get();
    return rows.map((row) => row.ledgerId).toSet();
  }

  /// Replaces the whole binding set in one transaction (PK guarantees uniqueness).
  Future<void> replaceBindings(String goalId, Set<String> ledgerIds) async {
    await transaction(() async {
      await (delete(goalLedgerBindings)..where((row) => row.goalId.equals(goalId))).go();
      final now = DateTime.now().toUtc().toIso8601String();
      for (final ledgerId in ledgerIds) {
        await into(goalLedgerBindings).insert(
              GoalLedgerBindingsCompanion.insert(
                goalId: goalId,
                ledgerId: ledgerId,
                createdAt: now,
              ),
            );
      }
    });
  }

  Future<List<int>> reachedThresholds(String goalId) async {
    final rows =
        await (select(goalMilestones)..where((row) => row.goalId.equals(goalId))).get();
    return rows.map((row) => row.thresholdPct).toList(growable: false);
  }

  /// Inserts a milestone at most once. Returns true only for the first insert.
  Future<bool> recordMilestoneOnce({
    required String goalId,
    required int thresholdPct,
    required String firstReachedDate,
  }) async {
    final existing = await (select(goalMilestones)
          ..where((row) =>
              row.goalId.equals(goalId) & row.thresholdPct.equals(thresholdPct)))
        .get();
    if (existing.isNotEmpty) {
      return false;
    }
    await into(goalMilestones).insert(
          GoalMilestonesCompanion.insert(
            goalId: goalId,
            thresholdPct: thresholdPct,
            firstReachedDate: firstReachedDate,
          ),
          mode: InsertMode.insertOrIgnore,
        );
    return true;
  }

  model.SavingsGoal _mapGoal(SavingsGoal row) => model.SavingsGoal(
        id: row.id,
        userId: row.userId,
        name: row.name,
        targetAmountCents: row.targetAmountCents,
        deadline: row.deadline,
        icon: row.icon,
        themeColor: row.themeColor,
        note: row.note,
        status: row.status,
        createdAt: DateTime.parse(row.createdAt),
        updatedAt: DateTime.parse(row.updatedAt),
      );
}
