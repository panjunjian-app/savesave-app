import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/services/balance_service.dart';
import 'core_providers.dart';

/// Key is a comma-separated, sorted set of ledger ids (empty = no ledgers).
final balanceBreakdownProvider =
    FutureProvider.family<BalanceBreakdown, String>((ref, key) {
  final ids = key.isEmpty ? <String>{} : key.split(',').toSet();
  return ref.watch(balanceServiceProvider).breakdownOf(ids);
});

String ledgerKeyOf(Iterable<String> ledgerIds) {
  final sorted = ledgerIds.toSet().toList()..sort();
  return sorted.join(',');
}
