import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/savings_goal.dart';
import '../domain/services/balance_service.dart';
import 'core_providers.dart';

final goalsProvider = StreamProvider<List<SavingsGoal>>((ref) {
  return ref.watch(goalDaoProvider).watchAll();
});

final activeGoalsProvider = Provider<AsyncValue<List<SavingsGoal>>>((ref) {
  return ref.watch(goalsProvider).whenData(
        (goals) => goals.where((goal) => goal.isActive).toList(growable: false),
      );
});

final goalByIdProvider = StreamProvider.family<SavingsGoal?, String>((ref, id) {
  return ref.watch(goalDaoProvider).watchById(id);
});

final boundLedgerIdsProvider = StreamProvider.family<Set<String>, String>((ref, goalId) {
  return ref.watch(goalDaoProvider).watchBoundLedgerIds(goalId);
});

final goalProgressProvider =
    FutureProvider.family<GoalProgress, String>((ref, goalId) {
  return ref.watch(balanceServiceProvider).progressOf(goalId);
});

/// First in-progress goal by ascending deadline (no deadline sorts last).
final focusedGoalProvider = Provider<AsyncValue<SavingsGoal?>>((ref) {
  return ref.watch(activeGoalsProvider).whenData((goals) {
    final dated = goals.where((goal) => goal.hasDeadline).toList()
      ..sort((a, b) => a.deadline!.compareTo(b.deadline!));
    if (dated.isNotEmpty) {
      return dated.first;
    }
    return goals.isEmpty ? null : goals.first;
  });
});
