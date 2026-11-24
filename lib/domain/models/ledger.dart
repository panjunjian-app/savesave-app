import 'package:freezed_annotation/freezed_annotation.dart';

part 'ledger.freezed.dart';
part 'ledger.g.dart';

/// A ledger groups bills; a goal may bind multiple ledgers.
@freezed
abstract class Ledger with _$Ledger {
  const Ledger._();

  const factory Ledger({
    required String id,
    required String userId,
    required String name,
    @Default('') String icon,
    @Default('#1F6F5C') String color,
    @Default(0) int sortOrder,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Ledger;

  factory Ledger.fromJson(Map<String, dynamic> json) => _$LedgerFromJson(json);

  static const String allKey = 'all';
}
