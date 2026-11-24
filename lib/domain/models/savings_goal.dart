import 'package:freezed_annotation/freezed_annotation.dart';

part 'savings_goal.freezed.dart';
part 'savings_goal.g.dart';

/// Savings goal. Progress is never persisted; it is derived from bound ledgers.
@freezed
abstract class SavingsGoal with _$SavingsGoal {
  const SavingsGoal._();

  const factory SavingsGoal({
    required String id,
    required String userId,
    required String name,
    required int targetAmountCents,
    String? deadline,
    @Default('') String icon,
    @Default('#1F6F5C') String themeColor,
    String? note,
    @Default('active') String status,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _SavingsGoal;

  factory SavingsGoal.fromJson(Map<String, dynamic> json) =>
      _$SavingsGoalFromJson(json);

  bool get isActive => status == 'active';
  bool get isAchieved => status == 'achieved';
  bool get hasDeadline => deadline != null && deadline!.isNotEmpty;
}
