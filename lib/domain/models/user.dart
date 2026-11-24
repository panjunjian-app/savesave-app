import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// Local user profile; `openid`/`email` are null for guest/local mode.
@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    String? openid,
    String? unionid,
    String? email,
    String? passwordHash,
    @Default('') String nickname,
    String? avatarUrl,
    @Default('guest') String loginType,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
