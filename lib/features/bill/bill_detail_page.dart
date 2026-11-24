import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/money.dart';
import '../../core/theme.dart';
import '../../state/providers.dart';

class BillDetailPage extends ConsumerWidget {
  const BillDetailPage({super.key, required this.billId});

  final String billId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billAsync = ref.watch(billByIdProvider(billId));
    return billAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(body: Center(child: Text('加载失败：$error'))),
      data: (bill) {
        if (bill == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('账单不存在')),
            body: const Center(child: Text('账单可能已被删除')),
          );
        }
        return Scaffold(
          appBar: AppBar(title: const Text('账单详情')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: <Widget>[
                      Text(
                        bill.isIncome ? '收入' : '支出',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${bill.isIncome ? '+' : '-'}${Money.formatCents(bill.amountCents)}',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: bill.isIncome ? AppColors.primary : AppColors.danger,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(title: const Text('日期'), trailing: Text(bill.billDate)),
              ListTile(title: const Text('备注'), trailing: Text(bill.note ?? '无')),
              ListTile(
                title: const Text('来源'),
                trailing: Text(
                  bill.isAiGenerated ? 'AI 识别（已确认）' : bill.isMigration ? '历史迁移' : '手动录入',
                ),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('删除账单'),
                      content: const Text('删除后目标进度会同步更新，确定删除吗？'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('取消'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('删除', style: TextStyle(color: AppColors.danger)),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    await ref.read(billServiceProvider).deleteBill(bill.id);
                    if (context.mounted) {
                      context.go('/bills');
                    }
                  }
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('删除这笔账单'),
              ),
            ],
          ),
        );
      },
    );
  }
}
