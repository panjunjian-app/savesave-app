import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/breakpoints.dart';
import '../../core/layout_tokens.dart';
import '../../core/money.dart';
import '../../core/theme.dart';
import '../../domain/models/bill.dart';
import '../../domain/models/category.dart';
import '../../domain/models/ledger.dart';
import '../../state/providers.dart';
import '../common/app_buttons.dart';
import '../common/responsive_scaffold.dart';

class BillDetailPage extends ConsumerWidget {
  const BillDetailPage({super.key, required this.billId});

  final String billId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billAsync = ref.watch(billByIdProvider(billId));
    return billAsync.when(
      loading: () => const ResponsiveScaffold(
        title: '账单详情',
        showAppBar: false,
        maxWidth: AppLayout.readerMaxWidth,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => ResponsiveScaffold(
        title: '账单详情',
        showAppBar: false,
        maxWidth: AppLayout.readerMaxWidth,
        body: Center(child: Text('加载失败：$error')),
      ),
      data: (bill) {
        if (bill == null) {
          return const ResponsiveScaffold(
            title: '账单不存在',
            maxWidth: AppLayout.readerMaxWidth,
            body: Center(child: Text('账单可能已被删除')),
          );
        }
        return ResponsiveScaffold(
          title: '账单详情',
          breadcrumb: '账单明细 / 账单详情',
          backLocation: '/bills',
          maxWidth: AppLayout.readerMaxWidth,
          body: context.isCompact
              ? _buildCompactBody(context, ref, bill)
              : _buildDesktopBody(context, ref, bill),
        );
      },
    );
  }

  /// 手机端：与改造前逐字一致的列表结构。
  Widget _buildCompactBody(BuildContext context, WidgetRef ref, Bill bill) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        _amountCard(context, bill),
        ListTile(title: const Text('日期'), trailing: Text(bill.billDate)),
        ListTile(title: const Text('备注'), trailing: Text(bill.note ?? '无')),
        ListTile(
          title: const Text('来源'),
          trailing: Text(_sourceLabel(bill)),
        ),
        const SizedBox(height: 24),
        AppButton.danger(
          label: '删除这笔账单',
          icon: Icons.delete_outline,
          onPressed: () => _confirmDelete(context, ref, bill),
        ),
      ],
    );
  }

  /// 桌面端：左 480 摘要卡 ｜ 右 480 元信息，删除按钮右对齐。
  Widget _buildDesktopBody(BuildContext context, WidgetRef ref, Bill bill) {
    final categories = ref.watch(categoriesProvider).valueOrNull ?? const <Category>[];
    final ledgers = ref.watch(ledgersProvider).valueOrNull ?? const <Ledger>[];
    final categoryName = categories
            .where((category) => category.id == bill.categoryId)
            .firstOrNull
            ?.name ??
        '—';
    final ledgerName =
        ledgers.where((ledger) => ledger.id == bill.ledgerId).firstOrNull?.name ??
            '—';

    return ListView(
      padding: context.pagePadding,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _amountCard(context, bill, desktop: true),
                  const SizedBox(height: AppLayout.cardGap),
                  Align(
                    alignment: Alignment.centerRight,
                    child: AppButton.danger(
                      label: '删除这笔账单',
                      icon: Icons.delete_outline,
                      onPressed: () => _confirmDelete(context, ref, bill),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppLayout.sectionGap),
            Expanded(
              child: Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: <Widget>[
                      _metaRow(context, '分类', categoryName),
                      _metaRow(context, '账本', ledgerName),
                      _metaRow(context, '日期', bill.billDate),
                      _metaRow(context, '来源', _sourceLabel(bill)),
                      _metaRow(context, '创建时间', _formatTime(bill.createdAt)),
                      _metaRow(context, '备注', bill.note ?? '无'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppLayout.sectionGap),
      ],
    );
  }

  Widget _amountCard(BuildContext context, Bill bill, {bool desktop = false}) {
    return Card(
      margin: desktop ? EdgeInsets.zero : null,
      child: Padding(
        padding: EdgeInsets.all(desktop ? 24 : 24),
        child: Column(
          children: <Widget>[
            Text(
              bill.isIncome ? '收入' : '支出',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Text(
              '${bill.isIncome ? '+' : '-'}${Money.formatCents(bill.amountCents)}',
              style: desktop
                  ? AppTheme.amountTextStyle(
                      AppBreakpoint.expanded,
                      color: bill.isIncome
                          ? AppColors.primary
                          : AppColors.danger,
                    )
                  : Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: bill.isIncome
                            ? AppColors.primary
                            : AppColors.danger,
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metaRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  String _sourceLabel(Bill bill) {
    if (bill.isAiGenerated) {
      return 'AI 识别（已确认）';
    }
    if (bill.isMigration) {
      return '历史迁移';
    }
    return '手动录入';
  }

  String _formatTime(DateTime time) {
    final local = time.toLocal();
    String two(int value) => value.toString().padLeft(2, '0');
    return '${local.year}-${two(local.month)}-${two(local.day)} '
        '${two(local.hour)}:${two(local.minute)}';
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Bill bill,
  ) async {
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
  }
}
