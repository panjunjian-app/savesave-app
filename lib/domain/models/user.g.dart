// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  id: json['id'] as String,
  openid: json['openid'] as String?,
  unionid: json['unionid'] as String?,
  email: json['email'] as String?,
  passwordHash: json['passwordHash'] as String?,
  nickname: json['nickname'] as String? ?? '',
  avatarUrl: json['avatarUrl'] as String?,
  loginType: json['loginType'] as String? ?? 'guest',
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'id': instance.id,
  'openid': instance.openid,
  'unionid': instance.unionid,
  'email': instance.email,
  'passwordHash': instance.passwordHash,
  'nickname': instance.nickname,
  'avatarUrl': instance.avatarUrl,
  'loginType': instance.loginType,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
