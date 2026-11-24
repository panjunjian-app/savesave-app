// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ledger.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Ledger _$LedgerFromJson(Map<String, dynamic> json) => _Ledger(
  id: json['id'] as String,
  userId: json['userId'] as String,
  name: json['name'] as String,
  icon: json['icon'] as String? ?? '',
  color: json['color'] as String? ?? '#1F6F5C',
  sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$LedgerToJson(_Ledger instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'name': instance.name,
  'icon': instance.icon,
  'color': instance.color,
  'sortOrder': instance.sortOrder,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
