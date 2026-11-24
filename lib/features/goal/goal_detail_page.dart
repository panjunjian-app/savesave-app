import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/money.dart';
import '../../core/theme.dart';
import '../../domain/services/balance_service.dart';
import '../../state/providers.dart';
import '../common/progress_ring.dart';

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
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(body: Center(child: Text('加载失败：$error'))),
      data: (goal) {
        if (goal == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('目标不存在')),
            body: const Center(child: Text('目标可能已被删除')),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text('${goal.icon} ${goal.name}'),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => context.go('/goals/edit/${goal.id}'),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: _deleteGoal,
              ),
            ],
          ),
          body: ListView(
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Text('目标金额', style: TextStyle(color: AppColors.textSecondary)),
                            Text(
                              Money.formatCents(goal.targetAmountCents),
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 8),
                            progressAsync.when(
                              loading: () => const Text('正在计算结余...'),
                              error: (_, __) => const Text('结余计算失败'),
                              data: (progress) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text('累计结余 ${Money.formatCents(progress.balanceCents)}'),
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
                        ),
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
                  child: breakdownAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
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
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const _SectionTitle(title: '绑定账本'),
              Card(
                child: ledgersAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const ListTile(title: Text('加载失败')),
                  data: (ledgers) {
                    final bound = ledgers.where((l) => ledgerIds.contains(l.id)).toList();
                    if (bound.isEmpty) {
                      return const ListTile(title: Text('尚未绑定账本'));
                    }
                    return Column(
                      children: bound
                          .map(
                            (ledger) => ListTile(
                              leading: Text(ledger.icon, style: const TextStyle(fontSize: 20)),
                              title: Text(ledger.name),
                              trailing: const Icon(Icons.link, size: 16),
                            ),
                          )
                          .toList(growable: false),
                    );
                  },
                ),
              ),
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
          ),
        );
      },
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
