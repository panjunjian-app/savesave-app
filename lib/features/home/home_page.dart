import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/breakpoints.dart';
import '../../core/layout_tokens.dart';
import '../../core/money.dart';
import '../../core/theme.dart';
import '../../domain/models/ledger.dart';
import '../../domain/models/savings_goal.dart';
import '../../state/providers.dart';
import '../common/adaptive_grid.dart';
import '../common/app_buttons.dart';
import '../common/empty_view.dart';
import '../common/progress_ring.dart';
import '../common/responsive_scaffold.dart';
import '../common/sync_status_badge.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsProvider);
    final ledgersAsync = ref.watch(ledgersProvider);
    final user = ref.watch(currentUserProvider);
    final compact = context.isCompact;

    return ResponsiveScaffold(
      title: '我的目标',
      actions: <Widget>[
        const SyncStatusBadge(),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          tooltip: '设置',
          onPressed: () => context.go('/settings'),
        ),
      ],
      // 桌面档由顶栏主按钮承担「新建目标」，手机端仍用 FAB（P0-5）。
      primaryAction: AppButton.primary(
        label: '新建目标',
        icon: Icons.add,
        onPressed: () => context.go('/goals/create'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/goals/create'),
        backgroundColor: AppColors.gold,
        child: const Icon(Icons.add),
      ),
      onRefresh: () async {
        ref.invalidate(goalsProvider);
        ref.invalidate(ledgersProvider);
      },
      body: ledgersAsync.when(
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
              iconSize: compact ? 56 : 64,
              maxWidth: compact ? null : 400,
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
                  iconSize: compact ? 56 : 64,
                  maxWidth: compact ? null : 400,
                );
              }
              return _buildGoalList(context, ref, goals, ledgers);
            },
          );
        },
      ),
    );
  }

  /// 目标列表：compact 保持改造前的单列列表；桌面为 3 指标条 + 卡片网格。
  Widget _buildGoalList(
    BuildContext context,
    WidgetRef ref,
    List<SavingsGoal> goals,
    List<Ledger> ledgers,
  ) {
    if (context.isCompact) {
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
    }

    final breakdown = ref
        .watch(
          balanceBreakdownProvider(
            ledgerKeyOf(ledgers.map((ledger) => ledger.id)),
          ),
        )
        .valueOrNull;
    return ListView(
      padding: context.pagePadding,
      children: <Widget>[
        _SummaryBar(
          goalCount: goals.length,
          ledgerCount: ledgers.length,
          totalBalanceCents: breakdown?.cumulativeNetCents,
        ),
        const SizedBox(height: AppLayout.sectionGap),
        AdaptiveGrid(
          children: goals
              .map((goal) => _GoalCard(goal: goal, showExtended: true))
              .toList(growable: false),
        ),
        const SizedBox(height: AppLayout.sectionGap),
      ],
    );
  }
}

/// 手机端汇总横幅（2 指标，改造前样式，逐像素不变）。
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

/// 桌面端汇总条：3 指标横向排列，高 ≤96（PRD §5 第 3 页）。
class _SummaryBar extends StatelessWidget {
  const _SummaryBar({
    required this.goalCount,
    required this.ledgerCount,
    required this.totalBalanceCents,
  });

  final int goalCount;
  final int ledgerCount;
  final int? totalBalanceCents;

  @override
  Widget build(BuildContext context) {
    final String balance = totalBalanceCents == null
        ? '—'
        : Money.formatCents(totalBalanceCents!);
    return Container(
      height: 88,
      padding: const EdgeInsets.symmetric(horizontal: 24),
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
          Container(width: 1, height: 40, color: Colors.white30),
          Expanded(
            child: _BannerMetric(value: balance, label: '总结余'),
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
  const _GoalCard({required this.goal, this.showExtended = false});

  final SavingsGoal goal;

  /// 桌面档展示更多字段（截止日 / 绑定账本 / 剩余天数）。
  final bool showExtended;

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
                  mainAxisSize: MainAxisSize.min,
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
                    if (showExtended) ...<Widget>[
                      const SizedBox(height: 8),
                      Text(
                        _extendedHint(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
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

  /// 桌面档补充的一行信息：截止日期 + 剩余天数。
  String _extendedHint() {
    if (!goal.hasDeadline) {
      return '未设截止日期 · 建议设定以启用进度提醒';
    }
    final parsed = DateTime.tryParse(goal.deadline!);
    if (parsed == null) {
      return '截止 ${goal.deadline}';
    }
    final days = parsed.difference(DateTime.now()).inDays;
    if (days < 0) {
      return '截止 ${formatDeadline(goal.deadline)} · 已超期 ${-days} 天';
    }
    return '截止 ${formatDeadline(goal.deadline)} · 剩余 $days 天';
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
