import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/user.dart';

/// Currently authenticated local user (null = guest mode).
final currentUserProvider = StateProvider<User?>((ref) => null);

final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});

final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(currentUserProvider)?.id;
});
