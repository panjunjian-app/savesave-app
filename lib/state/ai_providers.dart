import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core_providers.dart';

abstract final class AiPrefsKeys {
  static const String keyVerified = 'aiKeyVerified';
  static const String analysisConsented = 'aiAnalysisConsented';
  static const String consentKeyFingerprint = 'consentKeyFingerprint';
  static const String dataRevision = 'dataRevision';
  static const String imageConsentAccepted = 'ai_image_consent_accepted';
}

/// AI entries are enabled only when a key exists AND passed testConnection.
final aiAvailabilityProvider = FutureProvider<bool>((ref) async {
  final keyStore = ref.watch(aiKeyStoreProvider);
  if (!await keyStore.hasKey()) {
    return false;
  }
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(AiPrefsKeys.keyVerified) ?? false;
});

final aiKeyMaskedProvider = FutureProvider<String>((ref) {
  return ref.watch(aiKeyStoreProvider).maskedKey();
});

/// C4-specific consent flag (independent from C2/C3 consent).
final analysisConsentProvider = StateProvider<bool>((ref) => false);

/// Monotonic invalidation bus for AI analysis caches.
final dataRevisionProvider = StateProvider<int>((ref) => 0);

final aiConnectionTestProvider = FutureProvider<bool>((ref) async {
  final client = ref.watch(aiClientProvider);
  final probe = await client.testConnection();
  return probe.ok;
});
