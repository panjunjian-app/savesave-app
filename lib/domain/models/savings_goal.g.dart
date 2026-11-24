// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'savings_goal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SavingsGoal _$SavingsGoalFromJson(Map<String, dynamic> json) => _SavingsGoal(
  id: json['id'] as String,
  userId: json['userId'] as String,
  name: json['name'] as String,
  targetAmountCents: (json['targetAmountCents'] as num).toInt(),
  deadline: json['deadline'] as String?,
  icon: json['icon'] as String? ?? '',
  themeColor: json['themeColor'] as String? ?? '#1F6F5C',
  note: json['note'] as String?,
  status: json['status'] as String? ?? 'active',
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$SavingsGoalToJson(_SavingsGoal instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
      'targetAmountCents': instance.targetAmountCents,
      'deadline': instance.deadline,
      'icon': instance.icon,
      'themeColor': instance.themeColor,
      'note': instance.note,
      'status': instance.status,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
