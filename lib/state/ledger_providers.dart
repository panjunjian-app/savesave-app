import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/ledger.dart';
import 'core_providers.dart';

/// 'all' means every ledger; any other value is a concrete ledger id.
final selectedLedgerIdProvider = StateProvider<String>((ref) => Ledger.allKey);

final ledgersProvider = StreamProvider<List<Ledger>>((ref) {
  return ref.watch(ledgerDaoProvider).watchAll();
});

final ledgerByIdProvider = StreamProvider.family<Ledger?, String>((ref, id) {
  return ref.watch(ledgerDaoProvider).watchById(id);
});

final selectedLedgerProvider = Provider<AsyncValue<Ledger?>>((ref) {
  final id = ref.watch(selectedLedgerIdProvider);
  if (id == Ledger.allKey) {
    return const AsyncData<Ledger?>(null);
  }
  return ref.watch(ledgerByIdProvider(id));
});
