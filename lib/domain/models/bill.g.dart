// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Bill _$BillFromJson(Map<String, dynamic> json) => _Bill(
  id: json['id'] as String,
  ledgerId: json['ledgerId'] as String,
  categoryId: json['categoryId'] as String,
  type: json['type'] as String,
  amountCents: (json['amountCents'] as num).toInt(),
  billDate: json['billDate'] as String,
  note: json['note'] as String?,
  source: json['source'] as String? ?? 'manual',
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$BillToJson(_Bill instance) => <String, dynamic>{
  'id': instance.id,
  'ledgerId': instance.ledgerId,
  'categoryId': instance.categoryId,
  'type': instance.type,
  'amountCents': instance.amountCents,
  'billDate': instance.billDate,
  'note': instance.note,
  'source': instance.source,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
