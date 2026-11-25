import 'package:drift/drift.dart';

import '../database.dart';
import '../tables.dart';
import '../../domain/models/savings_goal.dart' as model;

part 'goal_dao.g.dart';

/// Data access for goals, ledger bindings and milestones.
///
/// v5 云同步：目标/绑定/里程碑的删除一律软删（is_deleted=1 + updated_at=now）；
/// 绑定替换改为软删旧行 + upsert 新行（保留同步轨迹）；查询过滤软删行。
@DriftAccessor(tables: [SavingsGoals, GoalLedgerBindings, GoalMilestones])
class GoalDao extends DatabaseAccessor<AppDatabase> with _$GoalDaoMixin {
  GoalDao(super.attachedDatabase);

  Stream<List<model.SavingsGoal>> watchAll() {
    final query = select(savingsGoals)
      ..where((row) => row.isDeleted.equals(false))
      ..orderBy([(row) => OrderingTerm.asc(row.createdAt)]);
    return query
        .watch()
        .map((rows) => rows.map(_mapGoal).toList(growable: false));
  }

  Stream<List<model.SavingsGoal>> watchByUser(String userId) {
    return (select(savingsGoals)
          ..where((row) =>
              row.userId.equals(userId) & row.isDeleted.equals(false)))
        .watch()
        .map((rows) => rows.map(_mapGoal).toList(growable: false));
  }

  Stream<model.SavingsGoal?> watchById(String id) {
    return (select(savingsGoals)
          ..where((row) => row.id.equals(id) & row.isDeleted.equals(false)))
        .watch()
        .map((rows) => rows.isEmpty ? null : _mapGoal(rows.first));
  }

  Future<model.SavingsGoal?> findById(String id) async {
    final rows = await (select(savingsGoals)
          ..where((row) => row.id.equals(id) & row.isDeleted.equals(false)))
        .get();
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

  /// 软删目标及其绑定/里程碑（架构 §9.7：删除可传播）。
  Future<void> remove(String goalId) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await transaction(() async {
      await (update(goalLedgerBindings)
            ..where((row) => row.goalId.equals(goalId)))
          .write(GoalLedgerBindingsCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(now),
      ));
      await (update(goalMilestones)
            ..where((row) => row.goalId.equals(goalId)))
          .write(GoalMilestonesCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(now),
      ));
      await (update(savingsGoals)..where((row) => row.id.equals(goalId))).write(
        SavingsGoalsCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(now),
        ),
      );
    });
  }

  Stream<Set<String>> watchBoundLedgerIds(String goalId) {
    return (select(goalLedgerBindings)
          ..where((row) =>
              row.goalId.equals(goalId) & row.isDeleted.equals(false)))
        .watch()
        .map((rows) => rows.map((row) => row.ledgerId).toSet());
  }

  Future<Set<String>> boundLedgerIds(String goalId) async {
    final rows = await (select(goalLedgerBindings)
          ..where((row) =>
              row.goalId.equals(goalId) & row.isDeleted.equals(false)))
        .get();
    return rows.map((row) => row.ledgerId).toSet();
  }

  /// Replaces the whole binding set in one transaction. PK guarantees
  /// uniqueness: 软删旧行（保留同步轨迹），新行用 insertOrReplace upsert，
  /// 因此同一 (goal, ledger) 反复绑定/解绑不会产生主键冲突。
  Future<void> replaceBindings(String goalId, Set<String> ledgerIds) async {
    await transaction(() async {
      final now = DateTime.now().toUtc().toIso8601String();
      final goalRows = await (select(savingsGoals)
            ..where((row) => row.id.equals(goalId)))
          .get();
      final userId = goalRows.isEmpty ? '' : goalRows.first.userId;

      await (update(goalLedgerBindings)
            ..where((row) => row.goalId.equals(goalId) & row.isDeleted.equals(false)))
          .write(GoalLedgerBindingsCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(now),
      ));
      for (final ledgerId in ledgerIds) {
        await into(goalLedgerBindings).insert(
              GoalLedgerBindingsCompanion.insert(
                goalId: goalId,
                ledgerId: ledgerId,
                userId: Value(userId),
                createdAt: now,
                updatedAt: Value(now),
              ),
              mode: InsertMode.insertOrReplace,
            );
      }
    });
  }

  Future<List<int>> reachedThresholds(String goalId) async {
    final rows = await (select(goalMilestones)
          ..where((row) =>
              row.goalId.equals(goalId) & row.isDeleted.equals(false)))
        .get();
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
              row.goalId.equals(goalId) &
              row.thresholdPct.equals(thresholdPct) &
              row.isDeleted.equals(false)))
        .get();
    if (existing.isNotEmpty) {
      return false;
    }
    final goalRows = await (select(savingsGoals)
          ..where((row) => row.id.equals(goalId)))
        .get();
    final userId = goalRows.isEmpty ? '' : goalRows.first.userId;
    await into(goalMilestones).insert(
          GoalMilestonesCompanion.insert(
            goalId: goalId,
            thresholdPct: thresholdPct,
            userId: Value(userId),
            firstReachedDate: firstReachedDate,
            updatedAt: Value(DateTime.now().toUtc().toIso8601String()),
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
