import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../state/providers.dart';
import '../common/empty_view.dart';

class LedgerListPage extends ConsumerWidget {
  const LedgerListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ledgersAsync = ref.watch(ledgersProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('账本管理')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/ledgers/create'),
        backgroundColor: AppColors.gold,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const _LedgerBottomBar(),
      body: ledgersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('加载失败：$error')),
        data: (ledgers) {
          if (ledgers.isEmpty) {
            return EmptyView(
              icon: Icons.book_outlined,
              title: '还没有账本',
              message: '账本是记账与目标进度的基础，创建一个开始吧。',
              actionLabel: '创建账本',
              onAction: () => context.go('/ledgers/create'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ledgers.length,
            itemBuilder: (context, index) {
              final ledger = ledgers[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.goldLight,
                    child: Text(ledger.icon),
                  ),
                  title: Text(ledger.name),
                  subtitle: const Text('查看账单与结余'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ref.read(selectedLedgerIdProvider.notifier).state = ledger.id;
                    context.go('/bills/new');
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _LedgerBottomBar extends StatelessWidget {
  const _LedgerBottomBar();

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: 1,
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            context.go('/home');
            break;
          case 1:
            context.go('/ledgers');
            break;
          case 2:
            context.go('/stats');
            break;
          case 3:
            context.go('/profile');
            break;
        }
      },
      destinations: const <NavigationDestination>[
        NavigationDestination(icon: Icon(Icons.flag_outlined), label: '目标'),
        NavigationDestination(icon: Icon(Icons.book_outlined), label: '账本'),
        NavigationDestination(icon: Icon(Icons.bar_chart_outlined), label: '统计'),
        NavigationDestination(icon: Icon(Icons.person_outline), label: '我的'),
      ],
    );
  }
}
