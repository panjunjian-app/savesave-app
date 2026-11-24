// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_dao.dart';

// ignore_for_file: type=lint
mixin _$GoalDaoMixin on DatabaseAccessor<AppDatabase> {
  $SavingsGoalsTable get savingsGoals => attachedDatabase.savingsGoals;
  $GoalLedgerBindingsTable get goalLedgerBindings =>
      attachedDatabase.goalLedgerBindings;
  $GoalMilestonesTable get goalMilestones => attachedDatabase.goalMilestones;
  GoalDaoManager get managers => GoalDaoManager(this);
}

class GoalDaoManager {
  final _$GoalDaoMixin _db;
  GoalDaoManager(this._db);
  $$SavingsGoalsTableTableManager get savingsGoals =>
      $$SavingsGoalsTableTableManager(_db.attachedDatabase, _db.savingsGoals);
  $$GoalLedgerBindingsTableTableManager get goalLedgerBindings =>
      $$GoalLedgerBindingsTableTableManager(
        _db.attachedDatabase,
        _db.goalLedgerBindings,
      );
  $$GoalMilestonesTableTableManager get goalMilestones =>
      $$GoalMilestonesTableTableManager(
        _db.attachedDatabase,
        _db.goalMilestones,
      );
}
