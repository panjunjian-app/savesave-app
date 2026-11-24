// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Category _$CategoryFromJson(Map<String, dynamic> json) => _Category(
  id: json['id'] as String,
  userId: json['userId'] as String,
  name: json['name'] as String,
  type: json['type'] as String,
  icon: json['icon'] as String? ?? '',
  color: json['color'] as String? ?? '#C6A15B',
  isCustom: json['isCustom'] as bool? ?? false,
  sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$CategoryToJson(_Category instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'name': instance.name,
  'type': instance.type,
  'icon': instance.icon,
  'color': instance.color,
  'isCustom': instance.isCustom,
  'sortOrder': instance.sortOrder,
};
