import 'package:drift/drift.dart';

import '../database.dart';
import '../tables.dart';

part 'balance_dao.g.dart';

/// Aggregated income/expense totals for one ledger.
class LedgerSumRow {
  const LedgerSumRow({
    required this.ledgerId,
    required this.incomeCents,
    required this.expenseCents,
  });

  final String ledgerId;
  final int incomeCents;
  final int expenseCents;

  int get netCents => incomeCents - expenseCents;
}

/// Read-only SQL aggregation used by BalanceService.
@DriftAccessor(tables: [Bills])
class BalanceDao extends DatabaseAccessor<AppDatabase> with _$BalanceDaoMixin {
  BalanceDao(super.attachedDatabase);

  Future<List<LedgerSumRow>> sumByLedger(Set<String> ledgerIds) async {
    if (ledgerIds.isEmpty) {
      return const <LedgerSumRow>[];
    }
    final income = bills.amountCents.sum(filter: bills.type.equals('income'));
    final expense = bills.amountCents.sum(filter: bills.type.equals('expense'));
    final query = selectOnly(bills)
      ..addColumns([bills.ledgerId, income, expense])
      ..where(bills.ledgerId.isIn(ledgerIds.toList(growable: false)))
      ..groupBy([bills.ledgerId]);

    final rows = await query.get();
    return rows
        .map(
          (row) => LedgerSumRow(
            ledgerId: row.read(bills.ledgerId) ?? '',
            incomeCents: row.read(income) ?? 0,
            expenseCents: row.read(expense) ?? 0,
          ),
        )
        .toList(growable: false);
  }

  Future<List<LedgerSumRow>> sumByLedgerRange({
    required Set<String> ledgerIds,
    required String from,
    required String to,
  }) async {
    if (ledgerIds.isEmpty) {
      return const <LedgerSumRow>[];
    }
    final income = bills.amountCents.sum(filter: bills.type.equals('income'));
    final expense = bills.amountCents.sum(filter: bills.type.equals('expense'));
    final query = selectOnly(bills)
      ..addColumns([bills.ledgerId, income, expense])
      ..where(bills.ledgerId.isIn(ledgerIds.toList(growable: false)) &
          bills.billDate.isBetweenValues(from, to))
      ..groupBy([bills.ledgerId]);

    final rows = await query.get();
    return rows
        .map(
          (row) => LedgerSumRow(
            ledgerId: row.read(bills.ledgerId) ?? '',
            incomeCents: row.read(income) ?? 0,
            expenseCents: row.read(expense) ?? 0,
          ),
        )
        .toList(growable: false);
  }
}
