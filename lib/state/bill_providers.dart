import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/bill.dart';
import 'core_providers.dart';

final billsByLedgerProvider = StreamProvider.family<List<Bill>, String>((ref, ledgerKey) {
  return ref.watch(billDaoProvider).watchByLedger(ledgerKey);
});

/// Range key is a Dart 3 record so family equality is structural.
final billsByRangeProvider = StreamProvider.family<
    List<Bill>,
    ({String from, String to, String ledgerKey})>((ref, key) {
  return ref.watch(billDaoProvider).watchByRange(
        from: key.from,
        to: key.to,
        ledgerKey: key.ledgerKey,
      );
});

final billByIdProvider = FutureProvider.family<Bill?, String>((ref, id) {
  return ref.watch(billDaoProvider).findById(id);
});

final recentBillsProvider = FutureProvider.family<List<Bill>, int>((ref, limit) {
  return ref.watch(billDaoProvider).findRecent(limit: limit);
});
