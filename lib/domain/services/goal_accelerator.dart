import 'package:decimal/decimal.dart';

import 'period_range_resolver.dart';

/// Strategy chosen by [GoalAccelerator.compute].
abstract final class GoalStrategy {
  static const String accelerate = 'accelerate';
  static const String buildPositive = 'buildPositive';
  static const String generic = 'generic';
}

/// Fully local, cent-precise quantification of a goal gap.
class GoalQuantization {
  const GoalQuantization({
    required this.hasGoal,
    required this.strategy,
    required this.targetCents,
    required this.balanceCents,
    required this.remainingCents,
    required this.remainingMonths,
    required this.monthlyNeededCents,
    required this.monthlyAvgNetCents,
    required this.monthlyGapCents,
    required this.deadline,
    required this.isMonthEstimate,
  });

  final bool hasGoal;
  final String strategy;
  final int targetCents;
  final int balanceCents;
  final int remainingCents;
  final int remainingMonths;
  final int monthlyNeededCents;
  final int monthlyAvgNetCents;
  final int monthlyGapCents;
  final String? deadline;
  final bool isMonthEstimate;
}

/// Computes the "how much more per month" figure without involving AI.
class GoalAccelerator {
  const GoalAccelerator();

  static const int _daysPerMonth = 30;
  static const int _defaultMonths = 6;

  /// [averageNetPerPeriod] must be the current-period average net balance in
  /// cents (income - expense). It is normalized to a monthly figure using the
  /// agreed Q32 coefficients before the gap is computed.
  GoalQuantization compute({
    required bool hasGoal,
    required int targetCents,
    required int balanceCents,
    String? deadline,
    required int averageNetPerPeriod,
    required PeriodType periodType,
    DateTime? now,
  }) {
    final today = now ?? DateTime.now();
    final averageMonthly = toMonthlyCents(averageNetPerPeriod, periodType);
    final normalizedTarget = targetCents > 0 ? targetCents : 0;
    final remaining = (normalizedTarget - balanceCents) > 0
        ? normalizedTarget - balanceCents
        : 0;

    final parsedDeadline = _parseDate(deadline);
    final int remainingMonths;
    if (parsedDeadline == null) {
      remainingMonths = _defaultMonths;
    } else {
      final days = parsedDeadline.difference(
        DateTime(today.year, today.month, today.day),
      ).inDays;
      remainingMonths = days <= 0 ? 1 : _ceilDiv(days, _daysPerMonth);
    }

    final monthlyNeeded = remaining == 0 ? 0 : _ceilDiv(remaining, remainingMonths);
    final gap = monthlyNeeded - averageMonthly;
    final monthlyGap = gap > 0 ? gap : 0;

    final strategy = !hasGoal
        ? GoalStrategy.generic
        : balanceCents > 0
            ? GoalStrategy.accelerate
            : GoalStrategy.buildPositive;

    return GoalQuantization(
      hasGoal: hasGoal,
      strategy: strategy,
      targetCents: normalizedTarget,
      balanceCents: balanceCents,
      remainingCents: remaining,
      remainingMonths: remainingMonths,
      monthlyNeededCents: monthlyNeeded,
      monthlyAvgNetCents: averageMonthly,
      monthlyGapCents: monthlyGap,
      deadline: deadline,
      isMonthEstimate: parsedDeadline == null,
    );
  }

  /// Fractional digits used only when a rational is non-terminating (e.g. /3).
  static const int _divisionPrecision = 10;

  /// Q32 conversion: week x4.345, month x1, quarter /3, year /12.
  int toMonthlyCents(int amountCents, PeriodType periodType) {
    final decimals = Decimal.fromInt(amountCents);
    switch (periodType) {
      case PeriodType.week:
        return (decimals * Decimal.parse('4.345')).round().toBigInt().toInt();
      case PeriodType.month:
        return amountCents;
      case PeriodType.quarter:
        return (decimals / Decimal.fromInt(3))
            .toDecimal(scaleOnInfinitePrecision: _divisionPrecision)
            .round()
            .toBigInt()
            .toInt();
      case PeriodType.year:
        return (decimals / Decimal.fromInt(12))
            .toDecimal(scaleOnInfinitePrecision: _divisionPrecision)
            .round()
            .toBigInt()
            .toInt();
    }
  }

  static int _ceilDiv(int dividend, int divisor) {
    if (divisor <= 0) {
      throw ArgumentError.value(divisor, 'divisor', 'must be positive');
    }
    return (dividend + divisor - 1) ~/ divisor;
  }

  static DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }
}
