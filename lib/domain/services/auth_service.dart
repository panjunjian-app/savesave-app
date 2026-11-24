import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/config.dart';
import '../../core/uuid.dart';
import '../../data/database.dart' hide User;
import '../models/user.dart';

class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Local email registration/sign-in plus guest fallback.
///
/// The project has no server: credentials live only in the on-device SQLite
/// database. Passwords are never stored in plaintext — they are hashed with
/// `sha256(salt + password)` before persisting. This deters casual reading of
/// the DB file but is not a KDF-grade protection; acceptable for a fully
/// offline personal bookkeeping app.
class AuthService {
  AuthService(this._db, {SharedPreferences? prefs})
      : _prefsOverride = prefs;

  static const String _localUserIdKey = 'local_user_id';

  final AppDatabase _db;
  SharedPreferences? _prefsOverride;

  Future<SharedPreferences> get _prefs async {
    return _prefsOverride ??= await SharedPreferences.getInstance();
  }

  static String _hashPassword(String password) {
    return sha256
        .convert(utf8.encode('${AppConfig.authPasswordSalt}:$password'))
        .toString();
  }

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

  /// Validates the password. Returns null when valid, otherwise a
  /// user-facing error message.
  static String? validatePassword(String password) {
    if (password.isEmpty) {
      return '请输入密码';
    }
    if (password.length < 6) {
      return '密码至少 6 位';
    }
    if (password.length > 64) {
      return '密码过长（最多 64 位）';
    }
    return null;
  }

  Future<User?> restoreLocalUser() async {
    final prefs = await _prefs;
    final id = prefs.getString(_localUserIdKey);
    if (id == null || id.isEmpty) {
      return null;
    }
    return _db.userDao.findById(id);
  }

  Future<User> signInAsGuest() async {
    final existing = await restoreLocalUser();
    if (existing != null) {
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

  /// Registers a new email account. Throws [AuthFailure] when the email is
  /// malformed or already registered on this device.
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
    final existing = await _db.userDao.findByEmail(normalized);
    if (existing != null) {
      throw const AuthFailure('该邮箱已注册，请直接登录');
    }

    // If the current guest user is unclaimed, upgrade it in place so the
    // guest's ledgers/goals keep working after registration.
    final guest = await restoreLocalUser();

    final now = DateTime.now().toUtc();
    final user = User(
      id: guest?.id ?? Uuid.v4(),
      email: normalized,
      passwordHash: _hashPassword(password),
      nickname:
          (nickname?.trim().isNotEmpty ?? false) ? nickname!.trim() : '邮箱用户',
      loginType: 'email',
      createdAt: guest?.createdAt ?? now,
      updatedAt: now,
    );
    await _db.userDao.save(user);
    await (await _prefs).setString(_localUserIdKey, user.id);
    return user;
  }

  /// Signs in an existing email account. Throws [AuthFailure] on unknown
  /// email or wrong password (deliberately generic on password mismatch to
  /// avoid confirming account existence).
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
    final existing = await _db.userDao.findByEmail(normalized);
    if (existing == null || existing.passwordHash == null) {
      throw const AuthFailure('该邮箱未注册，请先注册');
    }
    if (existing.passwordHash != _hashPassword(password)) {
      throw const AuthFailure('邮箱或密码不正确');
    }

    await (await _prefs).setString(_localUserIdKey, existing.id);
    return existing;
  }

  Future<void> signOut() async {
    await (await _prefs).remove(_localUserIdKey);
  }
}
