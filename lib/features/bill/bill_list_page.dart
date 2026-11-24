import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/money.dart';
import '../../core/theme.dart';
import '../../state/providers.dart';
import '../common/empty_view.dart';

class BillListPage extends ConsumerWidget {
  const BillListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ledgerKey = ref.watch(selectedLedgerIdProvider);
    final billsAsync = ref.watch(billsByLedgerProvider(ledgerKey));
    final ledgersAsync = ref.watch(ledgersProvider);
    final ledgerName = ledgerKey == 'all'
        ? '全部账本'
        : ledgersAsync.valueOrNull?.where((l) => l.id == ledgerKey).firstOrNull?.name ??
            '账本';

    return Scaffold(
      appBar: AppBar(
        title: Text('$ledgerName · 账单明细'),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (value) =>
                ref.read(selectedLedgerIdProvider.notifier).state = value,
            itemBuilder: (context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(value: 'all', child: Text('全部账本')),
              ...(ledgersAsync.valueOrNull ?? const []).map(
                (ledger) => PopupMenuItem<String>(
                  value: ledger.id,
                  child: Text(ledger.name),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/bills/new'),
        backgroundColor: AppColors.gold,
        child: const Icon(Icons.add),
      ),
      body: billsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('加载失败：$error')),
        data: (bills) {
          if (bills.isEmpty) {
            return const EmptyView(
              icon: Icons.receipt_long_outlined,
              title: '还没有账单',
              message: '点击右下角按钮记下第一笔收支。',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            itemCount: bills.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final bill = bills[index];
              return ListTile(
                title: Text(
                  bill.note ?? (bill.isIncome ? '收入' : '支出'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text('${bill.billDate} · ${bill.source}'),
                trailing: Text(
                  '${bill.isIncome ? '+' : '-'}${Money.formatCents(bill.amountCents)}',
                  style: TextStyle(
                    color: bill.isIncome ? AppColors.primary : AppColors.danger,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onTap: () => context.go('/bills/${bill.id}'),
              );
            },
          );
        },
      ),
    );
  }
}
