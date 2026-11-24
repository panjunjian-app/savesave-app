import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/money.dart';
import '../../core/theme.dart';
import '../../domain/services/period_range_resolver.dart';
import '../../domain/services/statistics_service.dart';
import '../../state/providers.dart';
import '../common/empty_view.dart';

class StatsPage extends ConsumerStatefulWidget {
  const StatsPage({super.key});

  @override
  ConsumerState<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends ConsumerState<StatsPage> {
  PeriodType _periodType = PeriodType.month;
  int _offset = 0;
  final List<Color> _palette = const <Color>[
    AppColors.primary,
    AppColors.gold,
    AppColors.danger,
    Color(0xFF4C9C86),
    Color(0xFF6B7772),
    Color(0xFFD9C7A3),
  ];

  @override
  Widget build(BuildContext context) {
    final ledgerKey = ref.watch(selectedLedgerIdProvider);
    final statsAsync = ref.watch(
      statsProvider(
        (ledgerKey: ledgerKey, periodType: _periodType, offset: _offset),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('统计报表'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.article_outlined),
            tooltip: 'AI 分析报告',
            onPressed: () => context.go('/analysis/report'),
          ),
        ],
      ),
      bottomNavigationBar: const _StatsBottomBar(),
      body: Column(
        children: <Widget>[
          _PeriodBar(
            type: _periodType,
            offset: _offset,
            onTypeChanged: (type) => setState(() {
              _periodType = type;
              _offset = 0;
            }),
            onOffsetChanged: (delta) =>
                setState(() => _offset = _offset + delta),
          ),
          Expanded(
            child: statsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('统计失败：$error')),
              data: (stats) => _StatsBody(stats: stats, palette: _palette),
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodBar extends StatelessWidget {
  const _PeriodBar({
    required this.type,
    required this.offset,
    required this.onTypeChanged,
    required this.onOffsetChanged,
  });

  final PeriodType type;
  final int offset;
  final ValueChanged<PeriodType> onTypeChanged;
  final ValueChanged<int> onOffsetChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: <Widget>[
          Expanded(
            child: SegmentedButton<PeriodType>(
              segments: const <ButtonSegment<PeriodType>>[
                ButtonSegment<PeriodType>(value: PeriodType.week, label: Text('周')),
                ButtonSegment<PeriodType>(value: PeriodType.month, label: Text('月')),
                ButtonSegment<PeriodType>(value: PeriodType.quarter, label: Text('季')),
                ButtonSegment<PeriodType>(value: PeriodType.year, label: Text('年')),
              ],
              selected: <PeriodType>{type},
              onSelectionChanged: (values) => onTypeChanged(values.first),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => onOffsetChanged(-1),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => onOffsetChanged(1),
          ),
        ],
      ),
    );
  }
}

class _StatsBody extends StatelessWidget {
  const _StatsBody({required this.stats, required this.palette});

  final StatsSnapshot stats;
  final List<Color> palette;

  @override
  Widget build(BuildContext context) {
    if (stats.billCount == 0) {
      return const EmptyView(
        icon: Icons.bar_chart_outlined,
        title: '该周期暂无数据',
        message: '切换周期或记一笔账单后再来看看。',
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text(
          '${stats.range.label} · ${stats.range.queryStart} 至 ${stats.range.queryEnd}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: _MetricCard(
                label: '收入',
                amount: stats.incomeCents,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MetricCard(
                label: '支出',
                amount: stats.expenseCents,
                color: AppColors.danger,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            Expanded(
              child: _MetricCard(
                label: '净结余',
                amount: stats.netCents,
                color: AppColors.gold,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text('储蓄率', style: TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      Text(
                        '${(stats.savingRate.toDouble() * 100).round()}%',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AppColors.primary,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('支出分类', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                if (stats.categories.isEmpty)
                  const Text('本周期没有支出')
                else
                  SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 48,
                        sections: stats.categories
                            .take(6)
                            .toList(growable: false)
                            .asMap()
                            .entries
                            .map(
                              (entry) => PieChartSectionData(
                                value: entry.value.ratio.toDouble(),
                                color: palette[entry.key % palette.length],
                                title: entry.value.name,
                                radius: 60,
                                titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                            )
                            .toList(growable: false),
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                ...stats.categories.take(6).toList(growable: false).asMap().entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: <Widget>[
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: palette[entry.key % palette.length],
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(entry.value.name)),
                            Text(Money.formatCents(entry.value.amountCents)),
                          ],
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final int amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            Text(
              Money.formatCents(amount),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsBottomBar extends StatelessWidget {
  const _StatsBottomBar();

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: 2,
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
