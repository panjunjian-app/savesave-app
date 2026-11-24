/// Application-wide configuration placeholders.
///
/// All third-party identifiers are intentionally kept as placeholders.
/// Replace them before packaging; never hard-code real credentials in source.
class AppConfig {
  const AppConfig._();

  static const String appName = '省省钱，存存钱';
  static const String databaseName = 'savesave.db';
  static const String backupDatabaseName = 'savesave.pre-v2.bak';

  /// Salt for the local password hash (sha256(salt + password)). The project
  /// has no server; this only prevents trivially-readable plaintext in the
  /// on-device SQLite file, not a real KDF-grade protection.
  static const String authPasswordSalt = 'savesave.v4.auth.salt';

  /// TODO(user): replace with the final applicationId / bundle identifier.
  static const String androidApplicationId = 'com.example.savesave';
  static const String iosBundleId = 'com.example.savesave';

  /// Fixed signing certificate alias used for every release build.
  static const String androidSigningAlias = 'savesave';

  /// Technical protection limit for amounts: 15 significant digits in cents.
  static const int maxAmountCents = 999999999999999;
}

/// BYOK (Bring Your Own Key) AI service constants.
class AiConfig {
  const AiConfig._();

  static const String endpoint = 'https://open.bigmodel.cn/api/paas/v4';
  static const String chatCompletionsPath = '/chat/completions';
  static const String modelId = 'glm-4.6v-flash';
  static const Duration timeout = Duration(seconds: 15);

  static const int maxTokensForConnectionTest = 8;
  static const int maxTokensForBillRecognition = 512;
  static const int maxTokensForAnalysis = 1500;

  /// Model self-reported confidence below this value is treated as "needs review".
  static const double confidenceThreshold = 0.8;

  static const String billRecognitionPrompt =
      'Extract bill fields from the image. Return strict JSON with keys: '
      'amount (string yuan), type (expense|income), category (string), '
      'date (YYYY-MM-DD), note (string), ledger (string), '
      'confidence (object with per-field numbers from 0 to 1). '
      'No markdown, no explanations.';
}
