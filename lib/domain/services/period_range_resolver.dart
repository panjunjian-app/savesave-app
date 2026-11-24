import 'package:intl/intl.dart';

/// Four natural period dimensions used by both the stats page and C4 analysis.
enum PeriodType { week, month, quarter, year }

/// Inclusive local-calendar date range for one period.
class PeriodRange {
  const PeriodRange({
    required this.type,
    required this.start,
    required this.end,
    required this.label,
  });

  final PeriodType type;
  final DateTime start;
  final DateTime end;
  final String label;

  String get queryStart => DateFormat('yyyy-MM-dd').format(start);
  String get queryEnd => DateFormat('yyyy-MM-dd').format(end);

  bool containsLocalDate(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return !day.isBefore(start) && !day.isAfter(end);
  }

  @override
  String toString() => 'PeriodRange($label, $queryStart..$queryEnd)';
}

/// The single source of truth for period boundaries.
///
/// All boundaries are computed in the device's local time zone. Bill dates are
/// local calendar date strings, so no UTC conversion is performed anywhere.
class PeriodRangeResolver {
  const PeriodRangeResolver();

  PeriodRange resolve(
    PeriodType type,
    DateTime anchor, {
    int offset = 0,
  }) {
    final day = DateTime(anchor.year, anchor.month, anchor.day);
    switch (type) {
      case PeriodType.week:
        final monday = day.subtract(Duration(days: day.weekday - 1));
        final start = monday.add(Duration(days: 7 * offset));
        final end = start.add(const Duration(days: 6));
        return PeriodRange(
          type: type,
          start: start,
          end: end,
          label: _weekLabel(start),
        );
      case PeriodType.month:
        final start = DateTime(day.year, day.month + offset, 1);
        final end = DateTime(start.year, start.month + 1, 0);
        return PeriodRange(
          type: type,
          start: start,
          end: end,
          label: DateFormat('yyyy-MM').format(start),
        );
      case PeriodType.quarter:
        final index = day.year * 4 + ((day.month - 1) ~/ 3) + offset;
        final year = (index / 4).floor();
        final quarter = index - year * 4 + 1;
        final firstMonth = 3 * (quarter - 1) + 1;
        return PeriodRange(
          type: type,
          start: DateTime(year, firstMonth, 1),
          end: DateTime(year, firstMonth + 3, 0),
          label: '$year-Q$quarter',
        );
      case PeriodType.year:
        final year = day.year + offset;
        return PeriodRange(
          type: type,
          start: DateTime(year, 1, 1),
          end: DateTime(year, 12, 31),
          label: '$year',
        );
    }
  }

  String toQueryStart(PeriodRange range) => range.queryStart;
  String toQueryEnd(PeriodRange range) => range.queryEnd;

  String _weekLabel(DateTime monday) {
    // ISO-8601 week: the week containing the first Thursday is week 1.
    final thursday = monday.add(const Duration(days: 3));
    final firstThursday = DateTime(thursday.year, 1, 4);
    final firstMonday =
        firstThursday.subtract(Duration(days: firstThursday.weekday - 1));
    final week = ((thursday.difference(firstMonday).inDays) / 7).floor() + 1;
    return '${thursday.year}-W${week.toString().padLeft(2, '0')}';
  }
}
