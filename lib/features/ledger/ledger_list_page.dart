import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/breakpoints.dart';
import '../../core/layout_tokens.dart';
import '../../core/money.dart';
import '../../core/theme.dart';
import '../../domain/models/bill.dart';
import '../../domain/models/ledger.dart';
import '../../state/providers.dart';
import '../common/adaptive_grid.dart';
import '../common/app_buttons.dart';
import '../common/empty_view.dart';
import '../common/responsive_scaffold.dart';

class LedgerListPage extends ConsumerWidget {
  const LedgerListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ledgersAsync = ref.watch(ledgersProvider);
    final compact = context.isCompact;

    return ResponsiveScaffold(
      title: '账本管理',
      primaryAction: AppButton.primary(
        label: '新建账本',
        icon: Icons.add,
        onPressed: () => context.go('/ledgers/create'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/ledgers/create'),
        backgroundColor: AppColors.gold,
        child: const Icon(Icons.add),
      ),
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
              iconSize: compact ? 56 : 64,
              maxWidth: compact ? null : 400,
            );
          }
          if (compact) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: ledgers.length,
              itemBuilder: (context, index) =>
                  _CompactLedgerTile(ledger: ledgers[index]),
            );
          }
          return ListView(
            padding: context.pagePadding,
            children: <Widget>[
              AdaptiveGrid(
                children: ledgers
                    .map((ledger) => _DesktopLedgerCard(ledger: ledger))
                    .toList(growable: false),
              ),
              const SizedBox(height: AppLayout.sectionGap),
            ],
          );
        },
      ),
    );
  }
}

/// 手机端账本项：与改造前的 Card + ListTile 完全一致。
class _CompactLedgerTile extends ConsumerWidget {
  const _CompactLedgerTile({required this.ledger});

  final Ledger ledger;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
  }
}

/// 桌面端账本卡：补全图标 / 名称 / 笔数 / 结余 / 最近日期，hover 边框转墨绿。
class _DesktopLedgerCard extends ConsumerStatefulWidget {
  const _DesktopLedgerCard({required this.ledger});

  final Ledger ledger;

  @override
  ConsumerState<_DesktopLedgerCard> createState() => _DesktopLedgerCardState();
}

class _DesktopLedgerCardState extends ConsumerState<_DesktopLedgerCard> {
  bool _hovered = false;

  void _open() {
    ref.read(selectedLedgerIdProvider.notifier).state = widget.ledger.id;
    context.go('/bills/new');
  }

  @override
  Widget build(BuildContext context) {
    final billsAsync = ref.watch(billsByLedgerProvider(widget.ledger.id));
    final breakdown =
        ref.watch(balanceBreakdownProvider(widget.ledger.id)).valueOrNull;
    final List<Bill> bills = billsAsync.valueOrNull ?? const <Bill>[];
    final int billCount = bills.length;
    final String? lastDate = bills.isEmpty ? null : bills.first.billDate;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radius),
          side: BorderSide(
            color: _hovered ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radius),
          onTap: _open,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    CircleAvatar(
                      backgroundColor: AppColors.goldLight,
                      child: Text(widget.ledger.icon),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.ledger.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _LedgerMetric(
                        label: '账单笔数',
                        value: '$billCount',
                      ),
                    ),
                    Expanded(
                      child: _LedgerMetric(
                        label: '当前结余',
                        value: breakdown == null
                            ? '—'
                            : Money.formatCents(breakdown.cumulativeNetCents),
                        highlight: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  lastDate == null ? '最近一笔：暂无记录' : '最近一笔：$lastDate',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LedgerMetric extends StatelessWidget {
  const _LedgerMetric({
    required this.label,
    required this.value,
    this.highlight,
  });

  final String label;
  final String value;
  final Color? highlight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: highlight ?? AppColors.textPrimary,
            fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
