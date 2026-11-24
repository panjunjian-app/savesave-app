import 'package:decimal/decimal.dart';

import '../../data/database.dart' hide Bill, Category;
import '../models/bill.dart';
import 'period_range_resolver.dart';

class CategoryStat {
  const CategoryStat({
    required this.categoryId,
    required this.name,
    required this.amountCents,
    required this.ratio,
    required this.count,
  });

  final String categoryId;
  final String name;
  final int amountCents;
  final Decimal ratio;
  final int count;
}

class TopExpense {
  const TopExpense({
    required this.billId,
    required this.categoryId,
    required this.categoryName,
    required this.amountCents,
    required this.date,
    required this.maskedNote,
  });

  final String billId;
  final String categoryId;
  final String categoryName;
  final int amountCents;
  final String date;
  final String? maskedNote;
}

class StatsSnapshot {
  const StatsSnapshot({
    required this.range,
    required this.incomeCents,
    required this.expenseCents,
    required this.netCents,
    required this.savingRate,
    required this.categories,
    required this.topExpenses,
    required this.billCount,
  });

  final PeriodRange range;
  final int incomeCents;
  final int expenseCents;
  final int netCents;
  final Decimal savingRate;
  final List<CategoryStat> categories;
  final List<TopExpense> topExpenses;
  final int billCount;
}

/// Aggregates local bill data for a fixed period. All numeric values are
/// computed here; AI (when enabled) only receives the finished snapshot.
class StatisticsService {
  StatisticsService(this._db, this._resolver);

  final AppDatabase _db;
  final PeriodRangeResolver _resolver;

  Future<StatsSnapshot> build({
    required String ledgerKey,
    required PeriodType periodType,
    DateTime? anchor,
    int offset = 0,
  }) async {
    final range = _resolver.resolve(periodType, anchor ?? DateTime.now(), offset: offset);
    final bills = await _db.billDao.queryByRange(
      from: range.queryStart,
      to: range.queryEnd,
      ledgerKey: ledgerKey,
    );
    final categories = await _db.categoryDao.findAll();
    final categoryNames = <String, String>{
      for (final category in categories) category.id: category.name,
    };
    return fromBills(
      bills: bills,
      range: range,
      categoryNames: categoryNames,
    );
  }

  StatsSnapshot fromBills({
    required List<Bill> bills,
    required PeriodRange range,
    required Map<String, String> categoryNames,
  }) {
    final expenses = bills.where((bill) => bill.isExpense).toList();
    final incomeCents = bills
        .where((bill) => bill.isIncome)
        .fold<int>(0, (sum, bill) => sum + bill.amountCents);
    final expenseCents = expenses.fold<int>(0, (sum, bill) => sum + bill.amountCents);
    final savingRate = incomeCents <= 0
        ? Decimal.zero
        : (Decimal.fromInt(incomeCents - expenseCents) /
            Decimal.fromInt(incomeCents))
            .toDecimal();
    final grouped = <String, int>{};
    final counts = <String, int>{};
    for (final expense in expenses) {
      grouped[expense.categoryId] =
          (grouped[expense.categoryId] ?? 0) + expense.amountCents;
      counts[expense.categoryId] = (counts[expense.categoryId] ?? 0) + 1;
    }
    final totalExpense = Decimal.fromInt(expenseCents <= 0 ? 1 : expenseCents);
    final stats = grouped.entries
        .map(
          (entry) => CategoryStat(
            categoryId: entry.key,
            name: categoryNames[entry.key] ?? '未分类',
            amountCents: entry.value,
            ratio: (Decimal.fromInt(entry.value) / totalExpense).toDecimal(),
            count: counts[entry.key] ?? 0,
          ),
        )
        .toList()
      ..sort((a, b) => b.amountCents.compareTo(a.amountCents));

    final sortedExpenses = expenses.toList()
      ..sort((a, b) => b.amountCents.compareTo(a.amountCents));
    final top = sortedExpenses.take(8).map((bill) {
      return TopExpense(
        billId: bill.id,
        categoryId: bill.categoryId,
        categoryName: categoryNames[bill.categoryId] ?? '未分类',
        amountCents: bill.amountCents,
        date: bill.billDate,
        maskedNote: _maskNote(bill.note),
      );
    }).toList(growable: false);

    return StatsSnapshot(
      range: range,
      incomeCents: incomeCents,
      expenseCents: expenseCents,
      netCents: incomeCents - expenseCents,
      savingRate: savingRate,
      categories: stats,
      topExpenses: top,
      billCount: bills.length,
    );
  }

  /// Notes are de-identified before leaving the device: keep at most 8 chars
  /// and replace digits/letters with '*' to avoid leaking merchant details.
  static String? _maskNote(String? note) {
    if (note == null || note.trim().isEmpty) {
      return null;
    }
    final truncated = note.trim().substring(0, note.trim().length.clamp(0, 8));
    return truncated.replaceAll(RegExp(r'[0-9A-Za-z]'), '*');
  }
}
