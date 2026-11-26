import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/breakpoints.dart';
import '../../core/layout_tokens.dart';
import '../../core/money.dart';
import '../../core/theme.dart';
import '../../domain/models/ledger.dart';
import '../../domain/models/savings_goal.dart';
import '../../domain/services/balance_service.dart';
import '../../state/providers.dart';
import '../common/progress_ring.dart';
import '../common/responsive_scaffold.dart';

class GoalDetailPage extends ConsumerStatefulWidget {
  const GoalDetailPage({super.key, required this.goalId});

  final String goalId;

  @override
  ConsumerState<GoalDetailPage> createState() => _GoalDetailPageState();
}

class _GoalDetailPageState extends ConsumerState<GoalDetailPage> {
  List<int> _reached = <int>[];

  @override
  void initState() {
    super.initState();
    _loadMilestones();
  }

  Future<void> _loadMilestones() async {
    final reached = await ref.read(goalDaoProvider).reachedThresholds(widget.goalId);
    if (mounted) {
      setState(() => _reached = reached..sort());
    }
  }

  Future<void> _deleteGoal() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除目标'),
        content: const Text('删除后无法恢复，绑定关系也会一并移除。确定删除吗？'),
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
    if (confirmed != true) {
      return;
    }
    await ref.read(goalServiceProvider).deleteGoal(widget.goalId);
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final goalAsync = ref.watch(goalByIdProvider(widget.goalId));
    final bindingsAsync = ref.watch(boundLedgerIdsProvider(widget.goalId));
    final progressAsync = ref.watch(goalProgressProvider(widget.goalId));
    final ledgerIds = bindingsAsync.valueOrNull ?? const <String>{};
    final breakdownAsync = ref.watch(balanceBreakdownProvider(ledgerKeyOf(ledgerIds)));
    final ledgersAsync = ref.watch(ledgersProvider);

    return goalAsync.when(
      loading: () => const ResponsiveScaffold(
        title: '目标详情',
        showAppBar: false,
        maxWidth: AppLayout.readerMaxWidth,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => ResponsiveScaffold(
        title: '目标详情',
        showAppBar: false,
        maxWidth: AppLayout.readerMaxWidth,
        body: Center(child: Text('加载失败：$error')),
      ),
      data: (goal) {
        if (goal == null) {
          return const ResponsiveScaffold(
            title: '目标不存在',
            maxWidth: AppLayout.readerMaxWidth,
            body: Center(child: Text('目标可能已被删除')),
          );
        }
        final compact = context.isCompact;
        return ResponsiveScaffold(
          title: '${goal.icon} ${goal.name}',
          breadcrumb: '目标 / ${goal.name}',
          backLocation: '/home',
          maxWidth: AppLayout.readerMaxWidth,
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: '编辑目标',
              onPressed: () => context.go('/goals/edit/${goal.id}'),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: '删除目标',
              onPressed: _deleteGoal,
            ),
          ],
          body: compact
              ? _buildCompactBody(goal, ledgerIds, breakdownAsync, progressAsync, ledgersAsync)
              : _buildDesktopBody(goal, ledgerIds, breakdownAsync, progressAsync, ledgersAsync),
        );
      },
    );
  }

  /// 手机端：与改造前逐字一致的单列卡片列表。
  Widget _buildCompactBody(
    SavingsGoal goal,
    Set<String> ledgerIds,
    AsyncValue<BalanceBreakdown> breakdownAsync,
    AsyncValue<GoalProgress> progressAsync,
    AsyncValue<List<Ledger>> ledgersAsync,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: <Widget>[
                progressAsync.when(
                  loading: () => const ProgressRing(percent: 0),
                  error: (_, __) => const ProgressRing(percent: 0),
                  data: (p) => ProgressRing(percent: p.displayPercent, size: 96),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _summaryColumn(goal, progressAsync),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        const _SectionTitle(title: '结余构成'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _breakdownColumn(breakdownAsync),
          ),
        ),
        const SizedBox(height: 12),
        const _SectionTitle(title: '绑定账本'),
        Card(child: _boundLedgers(ledgerIds, ledgersAsync)),
        const SizedBox(height: 12),
        const _SectionTitle(title: '里程碑'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              children: BalanceService.milestoneThresholds.map((threshold) {
                final reached = _reached.contains(threshold);
                return Chip(
                  avatar: Icon(
                    reached ? Icons.check_circle : Icons.radio_button_unchecked,
                    size: 16,
                    color: reached ? AppColors.primary : AppColors.textSecondary,
                  ),
                  label: Text('$threshold%'),
                  backgroundColor: reached ? AppColors.goldLight : null,
                );
              }).toList(growable: false),
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  /// 桌面端：左 480（进度环 160 + 金额 + 达成率）｜右 1.4 倍宽（结余 / 账本 / 里程碑）。
  Widget _buildDesktopBody(
    SavingsGoal goal,
    Set<String> ledgerIds,
    AsyncValue<BalanceBreakdown> breakdownAsync,
    AsyncValue<GoalProgress> progressAsync,
    AsyncValue<List<Ledger>> ledgersAsync,
  ) {
    return ListView(
      padding: context.pagePadding,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              flex: 480,
              child: Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: <Widget>[
                      progressAsync.when(
                        loading: () => const ProgressRing(percent: 0, size: 160),
                        error: (_, __) => const ProgressRing(percent: 0, size: 160),
                        data: (p) => ProgressRing(
                          percent: p.displayPercent,
                          size: 160,
                          strokeWidth: 12,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _summaryColumn(goal, progressAsync, desktop: true),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppLayout.sectionGap),
            Expanded(
              flex: 672,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '结余构成',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          _breakdownColumn(breakdownAsync),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppLayout.cardGap),
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '绑定账本',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          _boundLedgers(ledgerIds, ledgersAsync, dense: true),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppLayout.cardGap),
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '里程碑',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          _milestoneTimeline(goal.targetAmountCents),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppLayout.sectionGap),
      ],
    );
  }

  Widget _summaryColumn(
    SavingsGoal goal,
    AsyncValue<GoalProgress> progressAsync, {
    bool desktop = false,
  }) {
    final int targetCents = goal.targetAmountCents;
    return Column(
      crossAxisAlignment:
          desktop ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: <Widget>[
        const Text('目标金额', style: TextStyle(color: AppColors.textSecondary)),
        Text(
          Money.formatCents(targetCents),
          style: desktop
              ? AppTheme.amountTextStyle(AppBreakpoint.expanded)
              : Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        progressAsync.when(
          loading: () => const Text('正在计算结余...'),
          error: (_, __) => const Text('结余计算失败'),
          data: (progress) => Column(
            crossAxisAlignment: desktop
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: <Widget>[
              Text('累计结余 ${Money.formatCents(progress.balanceCents)}'),
              const SizedBox(height: 4),
              Text(
                '达成率 ${progress.displayPercent}%',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              if (progress.surplusCents > 0)
                Text(
                  '已超额完成 ${Money.formatCents(progress.surplusCents)}',
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              if (progress.hint != null)
                Text(
                  progress.hint!,
                  style: const TextStyle(
                    color: AppColors.danger,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _breakdownColumn(AsyncValue<BalanceBreakdown> breakdownAsync) {
    return breakdownAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Text('加载失败：$error'),
      data: (breakdown) => Column(
        children: <Widget>[
          _AmountRow(
            label: '本月收入',
            amount: breakdown.monthIncomeCents,
            color: AppColors.primary,
          ),
          _AmountRow(
            label: '本月支出',
            amount: breakdown.monthExpenseCents,
            color: AppColors.danger,
          ),
          const Divider(),
          _AmountRow(
            label: '本月净结余',
            amount: breakdown.monthNetCents,
            color: AppColors.primary,
          ),
          _AmountRow(
            label: '累计净结余',
            amount: breakdown.cumulativeNetCents,
            color: AppColors.gold,
          ),
        ],
      ),
    );
  }

  Widget _boundLedgers(
    Set<String> ledgerIds,
    AsyncValue<List<Ledger>> ledgersAsync, {
    bool dense = false,
  }) {
    return ledgersAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const ListTile(title: Text('加载失败')),
      data: (ledgers) {
        final bound = ledgers
            .where((ledger) => ledgerIds.contains(ledger.id))
            .toList(growable: false);
        if (bound.isEmpty) {
          return const ListTile(title: Text('尚未绑定账本'));
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: bound
              .map(
                (ledger) => ListTile(
                  dense: dense,
                  leading: Text(ledger.icon,
                      style: const TextStyle(fontSize: 20)),
                  title: Text(ledger.name),
                  trailing: const Icon(Icons.link, size: 16),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }

  /// 桌面端里程碑时间线：阈值 / 达成金额 / 状态 三列（PRD §5 第 10 页）。
  Widget _milestoneTimeline(int targetCents) {
    return Column(
      children: BalanceService.milestoneThresholds.map((threshold) {
        final bool reached = _reached.contains(threshold);
        final int amountCents = (targetCents * threshold / 100).round();
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: <Widget>[
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: reached ? AppColors.gold : AppColors.divider,
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 64,
                child: Text(
                  '$threshold%',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  Money.formatCents(amountCents),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
                  ),
                ),
              ),
              Text(
                reached ? '已达成' : '未达成',
                style: TextStyle(
                  fontSize: 12,
                  color: reached ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: reached ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        );
      }).toList(growable: false),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, left: 4),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({required this.label, required this.amount, required this.color});

  final String label;
  final int amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(
            Money.formatCents(amount),
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
