import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';

import 'config.dart';

/// Money helpers. Amounts are always handled as integer cents in storage.
abstract final class Money {
  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'zh_CN',
    symbol: '¥',
    decimalDigits: 2,
  );

  /// Parses a yuan string (optionally with ¥/￥/comma/万/千/百 suffix) into cents.
  ///
  /// Uses [Decimal] so no floating-point error enters the storage path.
  /// Throws [FormatException] for invalid input and [ArgumentError] when the
  /// technical 15-digit protection limit is exceeded.
  static int parseYuanToCents(String raw) {
    final cleaned = raw
        .replaceAll(RegExp(r'[¥￥,，\s]'), '')
        .replaceAll(RegExp(r'元$'), '');
    if (cleaned.isEmpty) {
      throw const FormatException('Empty amount');
    }

    final multiplierMatch = RegExp(r'([万千百])$').firstMatch(cleaned);
    final numericPart =
        multiplierMatch == null ? cleaned : cleaned.substring(0, multiplierMatch.start);
    if (numericPart.isEmpty) {
      throw const FormatException('Invalid amount');
    }

    Decimal value;
    try {
      value = Decimal.parse(numericPart);
    } catch (_) {
      throw FormatException('Invalid amount: $raw');
    }

    switch (multiplierMatch?.group(1)) {
      case '万':
        value *= Decimal.fromInt(10000);
        break;
      case '千':
        value *= Decimal.fromInt(1000);
        break;
      case '百':
        value *= Decimal.fromInt(100);
        break;
      default:
        break;
    }

    final cents = (value * Decimal.fromInt(100)).round().toBigInt().toInt();
    return enforceLimit(cents);
  }

  /// Enforces the 15-significant-digit technical protection limit.
  static int enforceLimit(int cents) {
    if (cents.abs() > AppConfig.maxAmountCents) {
      throw ArgumentError.value(cents, 'cents', '金额过大');
    }
    return cents;
  }

  /// Formats integer cents as a localized currency string, e.g. ¥1,234.50.
  static String formatCents(int cents) => _formatter.format(cents / 100);

  /// Formats integer cents as a plain string with two decimals, e.g. 1234.50.
  static String plainCents(int cents) {
    final negative = cents < 0;
    final absolute = cents.abs();
    final yuan = absolute ~/ 100;
    final fraction = absolute % 100;
    return '${negative ? '-' : ''}$yuan.${fraction.toString().padLeft(2, '0')}';
  }

  /// Encodes a value as a JSON-safe string (kept for legacy payload export).
  static String encodeCents(int cents) => jsonEncode(plainCents(cents));
}
