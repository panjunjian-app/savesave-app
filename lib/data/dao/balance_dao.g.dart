// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'balance_dao.dart';

// ignore_for_file: type=lint
mixin _$BalanceDaoMixin on DatabaseAccessor<AppDatabase> {
  $BillsTable get bills => attachedDatabase.bills;
  BalanceDaoManager get managers => BalanceDaoManager(this);
}

class BalanceDaoManager {
  final _$BalanceDaoMixin _db;
  BalanceDaoManager(this._db);
  $$BillsTableTableManager get bills =>
      $$BillsTableTableManager(_db.attachedDatabase, _db.bills);
}
