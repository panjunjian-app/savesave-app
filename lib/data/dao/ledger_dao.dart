import 'package:drift/drift.dart';

import '../database.dart';
import '../tables.dart';
import '../../domain/models/ledger.dart' as model;

part 'ledger_dao.g.dart';

/// Data access for ledgers.
@DriftAccessor(tables: [Ledgers])
class LedgerDao extends DatabaseAccessor<AppDatabase> with _$LedgerDaoMixin {
  LedgerDao(super.attachedDatabase);

  Stream<List<model.Ledger>> watchAll() {
    final query = select(ledgers)
      ..orderBy([
        (row) => OrderingTerm.asc(row.sortOrder),
        (row) => OrderingTerm.asc(row.createdAt),
      ]);
    return query
        .watch()
        .map((rows) => rows.map(_map).toList(growable: false));
  }

  Future<List<model.Ledger>> findAll() async {
    final rows = await select(ledgers).get();
    return rows.map(_map).toList(growable: false);
  }

  Stream<model.Ledger?> watchById(String id) {
    return (select(ledgers)..where((row) => row.id.equals(id)))
        .watch()
        .map((rows) => rows.isEmpty ? null : _map(rows.first));
  }

  Future<model.Ledger?> findById(String id) async {
    final rows = await (select(ledgers)..where((row) => row.id.equals(id))).get();
    return rows.isEmpty ? null : _map(rows.first);
  }

  Future<void> save(model.Ledger ledger) async {
    await into(ledgers).insert(
          LedgersCompanion.insert(
            id: ledger.id,
            userId: ledger.userId,
            name: ledger.name,
            icon: Value(ledger.icon),
            color: Value(ledger.color),
            sortOrder: Value(ledger.sortOrder),
            createdAt: ledger.createdAt.toUtc().toIso8601String(),
            updatedAt: ledger.updatedAt.toUtc().toIso8601String(),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  Future<int> deleteAll() => delete(ledgers).go();

  Future<void> remove(String ledgerId) async {
    await (delete(ledgers)..where((row) => row.id.equals(ledgerId))).go();
  }

  model.Ledger _map(Ledger row) => model.Ledger(
        id: row.id,
        userId: row.userId,
        name: row.name,
        icon: row.icon,
        color: row.color,
        sortOrder: row.sortOrder,
        createdAt: DateTime.parse(row.createdAt),
        updatedAt: DateTime.parse(row.updatedAt),
      );
}
