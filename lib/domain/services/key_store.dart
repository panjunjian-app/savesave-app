import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Encrypted storage for the user's BYOK API key.
///
/// The full key is never returned to the UI or written to logs; callers that
/// need to display it must use [maskedKey]. `shared_preferences` is reserved
/// for non-sensitive flags only.
class AiKeyStore {
  AiKeyStore({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
            );

  static const String _keyName = 'savesave.ai.api_key';

  final FlutterSecureStorage _storage;

  Future<String?> readKey() => _storage.read(key: _keyName);

  Future<void> saveKey(String key) async {
    final trimmed = key.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(key, 'key', 'API Key 不能为空');
    }
    await _storage.write(key: _keyName, value: trimmed);
  }

  Future<void> deleteKey() => _storage.delete(key: _keyName);

  Future<bool> hasKey() async {
    final key = await readKey();
    return key != null && key.isNotEmpty;
  }

  /// Returns a masked value such as `abcd****wxyz` (never the full key).
  Future<String> maskedKey() async {
    final key = await readKey();
    return key == null ? '' : mask(key);
  }

  /// Pure masking helper, safe to call with any non-null key.
  static String mask(String key) {
    if (key.length <= 8) {
      return '*' * key.length;
    }
    return '${key.substring(0, 4)}****${key.substring(key.length - 4)}';
  }

  /// Stable SHA-256 fingerprint used for AI consent invalidation.
  /// Returns an empty string when no key is configured.
  Future<String> keyFingerprint() async {
    final key = await readKey();
    if (key == null || key.isEmpty) {
      return '';
    }
    return sha256.convert(utf8.encode(key)).toString();
  }
}
