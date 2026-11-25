import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/api_client.dart';
import '../../core/config.dart';
import '../../core/uuid.dart';
import '../../data/database.dart' hide User;
import '../../domain/services/token_store.dart';
import '../models/user.dart';

class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

/// 本机旧密码校验回调（v1 本机账号「升级上云」引导用）。
///
/// v1.0.0 的账号是本地 sha256(salt+password) 哈希。云端登录 401 时，
/// 若本机旧哈希恰好匹配，则提示用户走升级入口而不是撞密码。
typedef LegacyHashChecker = Future<bool> Function(String email, String password);

/// 云端账号注册/登录/会话恢复（v3 改造，架构 §6.4）。
///
/// 旧逻辑（本地查重 + sha256 本地哈希落库）已被服务端 PBKDF2 + JWT 会话
/// 替代：本文件只保留格式校验、会话持久化与本地用户资料镜像。游客模式
/// 保持纯本地，数据永不上云（PRD G2）。
class AuthService {
  AuthService(
    this._db, {
    required this.remote,
    TokenStore? tokenStore,
    SharedPreferences? prefs,
    LegacyHashChecker? legacyHashChecker,
  })  : _tokenStore = tokenStore ?? TokenStore(),
        _prefsOverride = prefs,
        _legacyHashChecker = legacyHashChecker ?? _defaultLegacyHashChecker;

  static const String _localUserIdKey = 'local_user_id';

  final AppDatabase _db;

  /// 云端认证通道（register/login/restore/logout），测试可注入 mock。
  final AuthRemote remote;

  final TokenStore _tokenStore;
  final LegacyHashChecker _legacyHashChecker;
  SharedPreferences? _prefsOverride;

  Future<SharedPreferences> get _prefs async {
    return _prefsOverride ??= await SharedPreferences.getInstance();
  }

  /// 旧版本本地哈希（sha256(salt+password)），仅用于升级引导判断，非会话依据。
  static Future<bool> _defaultLegacyHashChecker(
    String email,
    String password,
  ) async {
    // 由依赖注入覆盖（需要 db 访问）；默认实现返回 false 避免误判。
    return false;
  }

  /// 当前注入的 TokenStore（AccountMigrator/providers 读取云端 uid 用）。
  TokenStore get tokenStore => _tokenStore;

  /// Validates the email shape. Returns null when valid, otherwise a
  /// user-facing error message.
  static String? validateEmail(String email) {
    final trimmed = email.trim();
    if (trimmed.isEmpty) {
      return '请输入邮箱';
    }
    final pattern = RegExp(
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
    );
    if (!pattern.hasMatch(trimmed)) {
      return '邮箱格式不正确';
    }
    if (trimmed.length > 254) {
      return '邮箱过长';
    }
    return null;
  }

  /// Validates the password. 云端要求 ≥8 位（S2），客户端与服务端保持一致。
  static String? validatePassword(String password) {
    if (password.isEmpty) {
      return '请输入密码';
    }
    if (password.length < 8) {
      return '密码至少 8 位';
    }
    if (password.length > 64) {
      return '密码过长（最多 64 位）';
    }
    return null;
  }

  // ============ 会话恢复（离线优先） ============

  /// 恢复当前用户：
  /// 1) secure storage 有云端 uid → 返回本地镜像行（离线安全，S10）；
  ///    若本地无该行（如重装后 IndexedDB 丢失），用缓存的云资料临时构造；
  /// 2) 无云端会话 → 回退 v1 本机账号/游客（离线模式，迁移待升级）。
  Future<User?> restoreLocalUser() async {
    final cached = await _tokenStore.readCachedProfile();
    if (cached != null) {
      final local = await _db.userDao.findById(cached.uid);
      if (local != null) {
        return local;
      }
      // 本地资料行缺失：以云端资料构造展示用镜像（下次登录会回写）。
      return User(
        id: cached.uid,
        email: cached.email.isEmpty ? null : cached.email,
        nickname: cached.nickname.isEmpty ? '云端用户' : cached.nickname,
        loginType: 'email',
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
      );
    }
    final prefs = await _prefs;
    final id = prefs.getString(_localUserIdKey);
    if (id == null || id.isEmpty) {
      return null;
    }
    return _db.userDao.findById(id);
  }

  // ============ 游客模式（纯本地，PRD G1/G2 不变） ============

  Future<User> signInAsGuest() async {
    final existing = await restoreLocalUser();
    if (existing != null && existing.loginType == 'guest') {
      return existing;
    }
    final now = DateTime.now().toUtc();
    final user = User(
      id: Uuid.v4(),
      nickname: '本地用户',
      loginType: 'guest',
      createdAt: now,
      updatedAt: now,
    );
    await _db.userDao.save(user);
    await (await _prefs).setString(_localUserIdKey, user.id);
    return user;
  }

  // ============ 云端注册/登录 ============

  /// 注册云端账号。成功后持久化会话（secure storage）并镜像本地资料行。
  /// 409 EMAIL_EXISTS → AuthFailure('该邮箱已注册，请直接登录')。
  Future<User> signUpWithEmail({
    required String email,
    required String password,
    String? nickname,
  }) async {
    final emailError = validateEmail(email);
    if (emailError != null) {
      throw AuthFailure(emailError);
    }
    final passwordError = validatePassword(password);
    if (passwordError != null) {
      throw AuthFailure(passwordError);
    }

    final normalized = email.trim().toLowerCase();
    final session = await _callRemote(
      () => remote.register(email: normalized, password: password, nickname: nickname),
    );
    return await _persistCloudSession(session, fallbackNickname: nickname);
  }

  /// 登录云端账号。401 统一文案（服务端防撞库）。
  /// 特例：本机存在旧版本 email 账号且本地哈希匹配 → 引导走升级入口。
  Future<User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final emailError = validateEmail(email);
    if (emailError != null) {
      throw AuthFailure(emailError);
    }
    if (password.isEmpty) {
      throw const AuthFailure('请输入密码');
    }

    final normalized = email.trim().toLowerCase();
    try {
      final session = await remote.login(email: normalized, password: password);
      return await _persistCloudSession(session);
    } on ApiFailure catch (error) {
      if (error.code == 'INVALID_CREDENTIALS') {
        final isLegacy = await _legacyHashChecker(normalized, password);
        if (isLegacy) {
          throw const AuthFailure('本机旧账号尚未升级云端，请在「升级为云端账号」中完成迁移');
        }
        throw const AuthFailure('邮箱或密码不正确');
      }
      // 其余错误码（RATE_LIMITED / VALIDATION_ERROR / INTERNAL…）统一转中文提示
      throw AuthFailure(error.message);
    } on NetworkUnavailableException {
      throw const AuthFailure('网络不可用，请检查网络后重试');
    } on SessionExpiredException {
      throw const AuthFailure('登录状态已失效，请重新登录');
    }
  }

  /// 统一包装远端调用：云端业务错误/网络失败统一转 [AuthFailure]（中文文案）。
  Future<T> _callRemote<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on ApiFailure catch (error) {
      throw AuthFailure(error.message);
    } on NetworkUnavailableException {
      throw const AuthFailure('网络不可用，请检查网络后重试');
    } on SessionExpiredException {
      throw const AuthFailure('登录状态已失效，请重新登录');
    }
  }

  /// 把云端会话落盘：secure storage 存 token，SQLite 镜像资料行（幂等）。
  Future<User> _persistCloudSession(
    AuthSessionResponse session, {
    String? fallbackNickname,
  }) async {
    if (session.userId.isEmpty) {
      throw const AuthFailure('云端返回异常，请稍后重试');
    }
    await _tokenStore.saveSession(session.toSession());

    final existing = await _db.userDao.findById(session.userId);
    final now = DateTime.now().toUtc();
    final user = (existing ?? User(
          id: session.userId,
          nickname: '邮箱用户',
          loginType: 'email',
          createdAt: now,
          updatedAt: now,
        )).copyWith(
      email: session.email,
      nickname: (existing?.nickname.isNotEmpty ?? false)
          ? existing!.nickname
          : (session.nickname.isNotEmpty
              ? session.nickname
              : (fallbackNickname?.trim().isNotEmpty ?? false
                  ? fallbackNickname!.trim()
                  : '邮箱用户')),
      loginType: 'email',
      updatedAt: now,
    );
    await _db.userDao.save(user);
    await (await _prefs).setString(_localUserIdKey, session.userId);
    return user;
  }

  // ============ 登出 ============

  /// 登出：吊销 refreshToken（尽力而为）+ 清 secure storage。
  /// 本地镜像数据保留（Q6：下次登录同账号无缝），但本机身份标记清除，
  /// 重启后停留在登录页而不是自动进入游客模式。
  Future<void> signOut() async {
    try {
      await remote.logout();
    } catch (_) {
      // 网络失败不阻塞本地登出。
    }
    await _tokenStore.clearSession();
    await (await _prefs).remove(_localUserIdKey);
  }

  /// 供「升级为云端账号」引导页判断：本机是否存在 v1 email 账号。
  Future<bool> hasLegacyEmailAccount() async {
    final prefs = await _prefs;
    final id = prefs.getString(_localUserIdKey);
    if (id == null || id.isEmpty) {
      return false;
    }
    final user = await _db.userDao.findById(id);
    return user != null && user.loginType == 'email';
  }
}

/// v1 本机哈希校验的真实实现（默认 legacyHashChecker 注入体）。
class LocalLegacyHashChecker {
  const LocalLegacyHashChecker(this._db);

  final AppDatabase _db;

  Future<bool> call(String email, String password) async {
    final user = await _db.userDao.findByEmail(email);
    if (user == null || user.passwordHash == null) {
      return false;
    }
    final hash = sha256
        .convert(utf8.encode('${AppConfig.authPasswordSalt}:$password'))
        .toString();
    return user.passwordHash == hash;
  }
}
