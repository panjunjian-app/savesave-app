import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Token 与云会话元数据的持久化存储（架构 §6.1）。
///
/// App 端落在 Keychain/Keystore（flutter_secure_storage），Web 端落在其
/// web 实现（localStorage）。GLM Key 走独立的 [AiKeyStore]，互不共享 key。
///
/// 测试可通过 [SecureKeyValueStore] 注入内存实现。
/// Token 明文只存在于本机安全存储，绝不写日志。
abstract class SecureKeyValueStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
  Future<void> clear();
}

/// flutter_secure_storage 实现（生产用）。
class FlutterSecureKeyValueStore implements SecureKeyValueStore {
  FlutterSecureKeyValueStore({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
            );

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) => _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);

  @override
  Future<void> clear() => _storage.deleteAll();
}

/// 云端会话快照（登录/注册/刷新统一结构）。
class CloudSession {
  const CloudSession({
    required this.userId,
    required this.email,
    required this.nickname,
    required this.accessToken,
    required this.refreshToken,
  });

  final String userId;
  final String email;
  final String nickname;
  final String accessToken;
  final String refreshToken;
}

/// secure_storage 封装：access/refresh/cloud_uid/email/nickname/迁移标记。
class TokenStore {
  TokenStore({SecureKeyValueStore? storage})
      : _storage = storage ?? FlutterSecureKeyValueStore();

  static const String _kAccessToken = 'savesave.cloud.access_token';
  static const String _kRefreshToken = 'savesave.cloud.refresh_token';
  static const String _kCloudUid = 'savesave.cloud.uid';
  static const String _kCloudEmail = 'savesave.cloud.email';
  static const String _kCloudNickname = 'savesave.cloud.nickname';
  static const String _kMigrationDone = 'savesave.cloud.migration_done';

  final SecureKeyValueStore _storage;

  Future<String?> readAccessToken() => _storage.read(_kAccessToken);
  Future<String?> readRefreshToken() => _storage.read(_kRefreshToken);

  /// 当前登录的云端用户 id；null 表示未登录云端。
  Future<String?> readCloudUid() => _storage.read(_kCloudUid);

  /// 是否已完成「本机数据升级上云」迁移（C8 一次性事务标记）。
  Future<bool> isMigrationDone() async =>
      await _storage.read(_kMigrationDone) == '1';

  Future<void> setMigrationDone() => _storage.write(_kMigrationDone, '1');

  /// 持久化一整个会话（登录/注册/刷新成功后调用）。
  Future<void> saveSession(CloudSession session) async {
    await _storage.write(_kAccessToken, session.accessToken);
    await _storage.write(_kRefreshToken, session.refreshToken);
    await _storage.write(_kCloudUid, session.userId);
    await _storage.write(_kCloudEmail, session.email);
    await _storage.write(_kCloudNickname, session.nickname);
  }

  /// 登出：清除全部云端会话数据（本地镜像按 Q6 默认保留）。
  Future<void> clearSession() async {
    await _storage.delete(_kAccessToken);
    await _storage.delete(_kRefreshToken);
    await _storage.delete(_kCloudUid);
    await _storage.delete(_kCloudEmail);
    await _storage.delete(_kCloudNickname);
  }

  /// 离线兜底：读取缓存的云账号展示信息（uid/email/nickname）。
  Future<({String uid, String email, String nickname})?> readCachedProfile() async {
    final uid = await _storage.read(_kCloudUid);
    if (uid == null || uid.isEmpty) {
      return null;
    }
    return (
      uid: uid,
      email: await _storage.read(_kCloudEmail) ?? '',
      nickname: await _storage.read(_kCloudNickname) ?? '',
    );
  }
}
