import 'package:freezed_annotation/freezed_annotation.dart';

part 'bill.freezed.dart';
part 'bill.g.dart';

/// Income/expense entry. [amountCents] is an integer measured in cents.
@freezed
abstract class Bill with _$Bill {
  const Bill._();

  const factory Bill({
    required String id,
    required String ledgerId,
    required String categoryId,
    required String type,
    required int amountCents,
    required String billDate,
    String? note,
    @Default('manual') String source,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Bill;

  factory Bill.fromJson(Map<String, dynamic> json) => _$BillFromJson(json);

  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';
  bool get isMigration => source == 'migration';
  bool get isAiGenerated => source == 'ai';
}
