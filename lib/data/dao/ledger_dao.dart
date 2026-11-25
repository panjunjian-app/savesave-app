import 'package:drift/drift.dart';

import '../database.dart';
import '../tables.dart';
import '../../domain/models/ledger.dart' as model;

part 'ledger_dao.g.dart';

/// Data access for ledgers.
///
/// v5 云同步：删除一律软删（is_deleted=1 + updated_at=now），
/// 查询过滤软删行。
@DriftAccessor(tables: [Ledgers])
class LedgerDao extends DatabaseAccessor<AppDatabase> with _$LedgerDaoMixin {
  LedgerDao(super.attachedDatabase);

  Stream<List<model.Ledger>> watchAll() {
    final query = select(ledgers)
      ..where((row) => row.isDeleted.equals(false))
      ..orderBy([
        (row) => OrderingTerm.asc(row.sortOrder),
        (row) => OrderingTerm.asc(row.createdAt),
      ]);
    return query
        .watch()
        .map((rows) => rows.map(_map).toList(growable: false));
  }

  Future<List<model.Ledger>> findAll() async {
    final rows =
        await (select(ledgers)..where((row) => row.isDeleted.equals(false))).get();
    return rows.map(_map).toList(growable: false);
  }

  Stream<model.Ledger?> watchById(String id) {
    return (select(ledgers)
          ..where((row) => row.id.equals(id) & row.isDeleted.equals(false)))
        .watch()
        .map((rows) => rows.isEmpty ? null : _map(rows.first));
  }

  Future<model.Ledger?> findById(String id) async {
    final rows = await (select(ledgers)
          ..where((row) => row.id.equals(id) & row.isDeleted.equals(false)))
        .get();
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

  /// 软删：is_deleted=1 + updated_at=now（架构 §9.7）。
  Future<void> remove(String ledgerId) async {
    await (update(ledgers)..where((row) => row.id.equals(ledgerId))).write(
      LedgersCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now().toUtc().toIso8601String()),
      ),
    );
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
