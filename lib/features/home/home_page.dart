import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/money.dart';
import '../../core/theme.dart';
import '../../domain/models/savings_goal.dart';
import '../../state/providers.dart';
import '../common/empty_view.dart';
import '../common/progress_ring.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsProvider);
    final ledgersAsync = ref.watch(ledgersProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的目标'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: '设置',
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/goals/create'),
        backgroundColor: AppColors.gold,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const _HomeBottomBar(currentIndex: 0),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(goalsProvider);
          ref.invalidate(ledgersProvider);
        },
        child: ledgersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('加载账本失败：$error')),
          data: (ledgers) {
            if (ledgers.isEmpty) {
              return EmptyView(
                icon: Icons.account_balance_wallet_outlined,
                title: '还没有账本',
                message: '先创建一个账本，才能通过记账自动累计目标进度。',
                actionLabel: '创建账本',
                onAction: () => context.go('/ledgers/create'),
              );
            }
            return goalsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('加载目标失败：$error')),
              data: (goals) {
                if (goals.isEmpty) {
                  return EmptyView(
                    icon: Icons.flag_outlined,
                    title: '${user?.nickname ?? '你好'}，开始第一个目标吧',
                    message: '设定金额与截止日期，绑定账本后进度会自动更新。',
                    actionLabel: '新建目标',
                    onAction: () => context.go('/goals/create'),
                  );
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  children: <Widget>[
                    _SummaryBanner(
                      goalCount: goals.length,
                      ledgerCount: ledgers.length,
                    ),
                    const SizedBox(height: 12),
                    ...goals.map((goal) => _GoalCard(goal: goal)),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _SummaryBanner extends StatelessWidget {
  const _SummaryBanner({required this.goalCount, required this.ledgerCount});

  final int goalCount;
  final int ledgerCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _BannerMetric(value: '$goalCount', label: '进行中的目标'),
          ),
          Container(width: 1, height: 40, color: Colors.white30),
          Expanded(
            child: _BannerMetric(value: '$ledgerCount', label: '已绑定账本'),
          ),
        ],
      ),
    );
  }
}

class _BannerMetric extends StatelessWidget {
  const _BannerMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}

class _GoalCard extends ConsumerWidget {
  const _GoalCard({required this.goal});

  final SavingsGoal goal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(goalProgressProvider(goal.id));
    final bindingsAsync = ref.watch(boundLedgerIdsProvider(goal.id));
    final boundCount = bindingsAsync.valueOrNull?.length ?? 0;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.go('/goals/${goal.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              progressAsync.when(
                loading: () => const SizedBox(
                  width: 64,
                  height: 64,
                  child: Center(child: CircularProgressIndicator(strokeWidth: 3)),
                ),
                error: (_, __) => const ProgressRing(percent: 0),
                data: (progress) => ProgressRing(percent: progress.displayPercent),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(goal.icon, style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            goal.name,
                            style: Theme.of(context).textTheme.titleMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (goal.isAchieved)
                          const Icon(Icons.verified, color: AppColors.gold, size: 18),
                      ],
                    ),
                    const SizedBox(height: 8),
                    progressAsync.when(
                      loading: () => const Text('计算中...'),
                      error: (_, __) => const Text('进度计算失败'),
                      data: (progress) => Text(
                        '已结余 ${Money.formatCents(progress.balanceCents)} / '
                        '目标 ${Money.formatCents(goal.targetAmountCents)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      goal.hasDeadline
                          ? '截止 ${goal.deadline} · 绑定账本 $boundCount 个'
                          : '未设截止日期 · 绑定账本 $boundCount 个',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeBottomBar extends StatelessWidget {
  const _HomeBottomBar({required this.currentIndex});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
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

/// Small helper used by several pages for deadline display.
String formatDeadline(String? deadline) {
  if (deadline == null || deadline.isEmpty) {
    return '未设置';
  }
  final parsed = DateTime.tryParse(deadline);
  return parsed == null ? deadline : DateFormat('yyyy年MM月dd日').format(parsed);
}
