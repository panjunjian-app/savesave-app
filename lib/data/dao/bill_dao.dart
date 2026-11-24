import 'package:drift/drift.dart';

import '../database.dart';
import '../tables.dart';
import '../../domain/models/bill.dart' as model;

part 'bill_dao.g.dart';

/// Data access for bills. All range queries compare local calendar date strings.
@DriftAccessor(tables: [Bills])
class BillDao extends DatabaseAccessor<AppDatabase> with _$BillDaoMixin {
  BillDao(super.attachedDatabase);

  Stream<List<model.Bill>> watchByLedger(String ledgerKey) {
    final query = select(bills);
    if (ledgerKey != 'all') {
      query.where((row) => row.ledgerId.equals(ledgerKey));
    }
    query.orderBy([
      (row) => OrderingTerm.desc(row.billDate),
      (row) => OrderingTerm.desc(row.createdAt),
    ]);
    return query
        .watch()
        .map((rows) => rows.map(_map).toList(growable: false));
  }

  Stream<List<model.Bill>> watchByRange({
    required String from,
    required String to,
    required String ledgerKey,
  }) {
    return _rangeQuery(from: from, to: to, ledgerKey: ledgerKey)
        .watch()
        .map((rows) => rows.map(_map).toList(growable: false));
  }

  Future<List<model.Bill>> queryByRange({
    required String from,
    required String to,
    required String ledgerKey,
  }) async {
    final rows = await _rangeQuery(from: from, to: to, ledgerKey: ledgerKey).get();
    return rows.map(_map).toList(growable: false);
  }

  Future<List<model.Bill>> findRecent({int limit = 20}) async {
    final rows = await (select(bills)
          ..orderBy([(row) => OrderingTerm.desc(row.createdAt)])
          ..limit(limit))
        .get();
    return rows.map(_map).toList(growable: false);
  }

  Future<model.Bill?> findById(String id) async {
    final rows = await (select(bills)..where((row) => row.id.equals(id))).get();
    return rows.isEmpty ? null : _map(rows.first);
  }

  Future<void> save(model.Bill bill) async {
    await into(bills).insert(
          BillsCompanion.insert(
            id: bill.id,
            ledgerId: bill.ledgerId,
            categoryId: bill.categoryId,
            type: bill.type,
            amountCents: bill.amountCents,
            billDate: bill.billDate,
            note: Value(bill.note),
            source: Value(bill.source),
            createdAt: bill.createdAt.toUtc().toIso8601String(),
            updatedAt: bill.updatedAt.toUtc().toIso8601String(),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  Future<int> deleteAll() => delete(bills).go();

  Future<void> remove(String billId) async {
    await (delete(bills)..where((row) => row.id.equals(billId))).go();
  }

  SimpleSelectStatement<Bills, Bill> _rangeQuery({
    required String from,
    required String to,
    required String ledgerKey,
  }) {
    return select(bills)
      ..where((row) {
        final inRange = row.billDate.isBetweenValues(from, to);
        return ledgerKey == 'all' ? inRange : inRange & row.ledgerId.equals(ledgerKey);
      })
      ..orderBy([
        (row) => OrderingTerm.desc(row.billDate),
        (row) => OrderingTerm.desc(row.amountCents),
      ]);
  }

  model.Bill _map(Bill row) => model.Bill(
        id: row.id,
        ledgerId: row.ledgerId,
        categoryId: row.categoryId,
        type: row.type,
        amountCents: row.amountCents,
        billDate: row.billDate,
        note: row.note,
        source: row.source,
        createdAt: DateTime.parse(row.createdAt),
        updatedAt: DateTime.parse(row.updatedAt),
      );
}
