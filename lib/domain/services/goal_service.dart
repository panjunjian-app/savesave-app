import '../../core/money.dart';
import '../../core/uuid.dart';
import '../../data/database.dart' hide SavingsGoal;
import '../models/savings_goal.dart';
import 'balance_service.dart';

/// Failures produced by goal validation.
class GoalValidationFailure implements Exception {
  const GoalValidationFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Application service for goal CRUD. UI never writes DAOs directly.
class GoalService {
  GoalService(this._db, this._balanceService);

  final AppDatabase _db;
  final BalanceService _balanceService;

  Future<SavingsGoal> createGoal({
    required String userId,
    required String name,
    required int targetAmountCents,
    String? deadline,
    String icon = '',
    String themeColor = '#1F6F5C',
    String? note,
    Set<String> ledgerIds = const <String>{},
  }) async {
    _validateName(name);
    Money.enforceLimit(targetAmountCents);
    if (targetAmountCents <= 0) {
      throw const GoalValidationFailure('目标金额必须大于 0');
    }
    final now = DateTime.now().toUtc();
    final goal = SavingsGoal(
      id: Uuid.v4(),
      userId: userId,
      name: name.trim(),
      targetAmountCents: targetAmountCents,
      deadline: deadline,
      icon: icon,
      themeColor: themeColor,
      note: note,
      status: 'active',
      createdAt: now,
      updatedAt: now,
    );
    await _db.transaction(() async {
      await _db.goalDao.save(goal);
      if (ledgerIds.isNotEmpty) {
        await _db.goalDao.replaceBindings(goal.id, ledgerIds);
      }
    });
    _balanceService.invalidate(ledgerIds);
    return goal;
  }

  Future<void> updateGoal({
    required SavingsGoal goal,
    required String name,
    required int targetAmountCents,
    String? deadline,
    String icon = '',
    String themeColor = '#1F6F5C',
    String? note,
    Set<String> ledgerIds = const <String>{},
  }) async {
    _validateName(name);
    Money.enforceLimit(targetAmountCents);
    if (targetAmountCents <= 0) {
      throw const GoalValidationFailure('目标金额必须大于 0');
    }
    final previous = await _db.goalDao.boundLedgerIds(goal.id);
    final updated = goal.copyWith(
      name: name.trim(),
      targetAmountCents: targetAmountCents,
      deadline: deadline,
      icon: icon,
      themeColor: themeColor,
      note: note,
      updatedAt: DateTime.now().toUtc(),
    );
    await _db.transaction(() async {
      await _db.goalDao.save(updated);
      await _db.goalDao.replaceBindings(goal.id, ledgerIds);
    });
    _balanceService.invalidate(previous.union(ledgerIds));
  }

  Future<void> deleteGoal(String goalId) async {
    final bound = await _db.goalDao.boundLedgerIds(goalId);
    await _db.goalDao.remove(goalId);
    _balanceService.invalidate(bound);
  }

  Future<void> markAchievedIfNeeded(String goalId, int displayPercent) async {
    if (displayPercent >= 100) {
      await _db.goalDao.updateStatus(goalId, 'achieved');
    }
  }

  static void _validateName(String name) {
    if (name.trim().isEmpty) {
      throw const GoalValidationFailure('请输入目标名称');
    }
    if (name.trim().length > 40) {
      throw const GoalValidationFailure('目标名称不超过 40 个字');
    }
  }
}
