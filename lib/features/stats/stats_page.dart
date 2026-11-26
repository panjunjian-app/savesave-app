import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/breakpoints.dart';
import '../../core/layout_tokens.dart';
import '../../core/money.dart';
import '../../core/theme.dart';
import '../../domain/models/ledger.dart';
import '../../domain/services/period_range_resolver.dart';
import '../../domain/services/statistics_service.dart';
import '../../state/providers.dart';
import '../common/app_buttons.dart';
import '../common/data_table_view.dart';
import '../common/empty_view.dart';
import '../common/responsive_scaffold.dart';

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
    final range = ref.watch(periodRangeResolverProvider).resolve(
          _periodType,
          DateTime.now(),
          offset: _offset,
        );
    final compact = context.isCompact;

    return ResponsiveScaffold(
      title: '统计报表',
      fillHeight: true,
      actions: <Widget>[
        if (compact)
          IconButton(
            icon: const Icon(Icons.article_outlined),
            tooltip: 'AI 分析报告',
            onPressed: () => context.go('/analysis/report'),
          ),
      ],
      body: compact
          ? Column(
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
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, _) => Center(child: Text('统计失败：$error')),
                    data: (stats) =>
                        _StatsBody(stats: stats, palette: _palette),
                  ),
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(
                  width: AppLayout.statsFilterWidth,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      32,
                      24,
                      AppLayout.sectionGap,
                      24,
                    ),
                    child: _FilterPanel(
                      periodType: _periodType,
                      rangeLabel: range.label,
                      onTypeChanged: (type) => setState(() {
                        _periodType = type;
                        _offset = 0;
                      }),
                      onPrev: () => setState(() => _offset--),
                      onNext: () => setState(() => _offset++),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      0,
                      24,
                      32,
                      24,
                    ),
                    child: statsAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, _) => Center(child: Text('统计失败：$error')),
                      data: (stats) => _StatsDesktopBody(
                        stats: stats,
                        palette: _palette,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

/// 手机端周期条（改造前样式）。
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

/// 桌面端左侧 240px 筛选栏：账本、周期竖排、日期导航、AI 报告入口。
class _FilterPanel extends ConsumerWidget {
  const _FilterPanel({
    required this.periodType,
    required this.rangeLabel,
    required this.onTypeChanged,
    required this.onPrev,
    required this.onNext,
  });

  final PeriodType periodType;
  final String rangeLabel;
  final ValueChanged<PeriodType> onTypeChanged;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  static const Map<PeriodType, String> _labels = <PeriodType, String>{
    PeriodType.week: '周',
    PeriodType.month: '月',
    PeriodType.quarter: '季',
    PeriodType.year: '年',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ledgerKey = ref.watch(selectedLedgerIdProvider);
    final ledgers = ref.watch(ledgersProvider).valueOrNull ?? const <Ledger>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const Text(
          '账本',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: ledgerKey,
          decoration: const InputDecoration(isDense: true),
          items: <DropdownMenuItem<String>>[
            const DropdownMenuItem<String>(
              value: Ledger.allKey,
              child: Text('全部账本'),
            ),
            ...ledgers.map(
              (ledger) => DropdownMenuItem<String>(
                value: ledger.id,
                child: Text(ledger.name),
              ),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              ref.read(selectedLedgerIdProvider.notifier).state = value;
            }
          },
        ),
        const SizedBox(height: AppLayout.sectionGap),
        const Text(
          '周期',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        for (final PeriodType type in PeriodType.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: _FilterTile(
              label: _labels[type] ?? type.name,
              selected: type == periodType,
              onTap: () => onTypeChanged(type),
            ),
          ),
        const SizedBox(height: AppLayout.sectionGap),
        const Text(
          '日期',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        Row(
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.chevron_left),
              tooltip: '上一周期',
              onPressed: onPrev,
            ),
            Expanded(
              child: Text(
                rangeLabel,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              tooltip: '下一周期',
              onPressed: onNext,
            ),
          ],
        ),
        const SizedBox(height: AppLayout.sectionGap),
        AppButton.secondary(
          label: 'AI 分析报告',
          icon: Icons.article_outlined,
          onPressed: () => context.go('/analysis/report'),
        ),
      ],
    );
  }
}

class _FilterTile extends StatelessWidget {
  const _FilterTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: selected ? AppColors.primary : AppColors.textSecondary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

/// 手机端统计主体（改造前样式）。
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
              child: _SavingRateCard(rate: stats.savingRate.toDouble()),
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
                _pie(stats, 200),
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

  Widget _pie(StatsSnapshot stats, double height) {
    if (stats.categories.isEmpty) {
      return const Text('本周期没有支出');
    }
    return SizedBox(
      height: height,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: height / 4,
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
                  radius: height / 3.4,
                  titleStyle: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              )
              .toList(growable: false),
        ),
      ),
    );
  }
}

/// 桌面端统计主体：4 指标 → 图表（320）→ 分类明细表格（含占比）。
class _StatsDesktopBody extends StatelessWidget {
  const _StatsDesktopBody({required this.stats, required this.palette});

  final StatsSnapshot stats;
  final List<Color> palette;

  @override
  Widget build(BuildContext context) {
    if (stats.billCount == 0) {
      return const EmptyView(
        icon: Icons.bar_chart_outlined,
        title: '该周期暂无数据',
        message: '切换周期或记一笔账单后再来看看。',
        iconSize: 64,
        maxWidth: 400,
      );
    }
    final categories = stats.categories;
    final double tableHeight = AppLayout.tableHeaderHeight +
        (categories.isEmpty ? 0 : categories.length * AppLayout.tableRowHeight);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
                flat: true,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MetricCard(
                label: '支出',
                amount: stats.expenseCents,
                color: AppColors.danger,
                flat: true,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MetricCard(
                label: '净结余',
                amount: stats.netCents,
                color: AppColors.gold,
                flat: true,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _SavingRateCard(
                rate: stats.savingRate.toDouble(),
                flat: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('支出分类', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                SizedBox(
                  height: 320,
                  child: stats.categories.isEmpty
                      ? const Center(child: Text('本周期没有支出'))
                      : PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 80,
                            sections: stats.categories
                                .take(6)
                                .toList(growable: false)
                                .asMap()
                                .entries
                                .map(
                                  (entry) => PieChartSectionData(
                                    value: entry.value.ratio.toDouble(),
                                    color: palette[
                                        entry.key % palette.length],
                                    title: entry.value.name,
                                    radius: 96,
                                    titleStyle: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                )
                                .toList(growable: false),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppLayout.sectionGap),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('分类明细', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                SizedBox(
                  height: tableHeight == AppLayout.tableHeaderHeight
                      ? 120
                      : tableHeight,
                  child: AppTableView<CategoryStat>(
                    rows: categories,
                    emptyHint: '本周期没有支出',
                    rowHeight: AppLayout.tableRowHeight,
                    columns: <AppTableColumn<CategoryStat>>[
                      AppTableColumn<CategoryStat>(
                        label: '分类',
                        flex: 3,
                        minWidth: 120,
                        cell: (context, row) => Text(row.name),
                      ),
                      AppTableColumn<CategoryStat>(
                        label: '金额',
                        flex: 2,
                        minWidth: 120,
                        numeric: true,
                        align: TextAlign.right,
                        cell: (context, row) =>
                            Text(Money.formatCents(row.amountCents)),
                      ),
                      AppTableColumn<CategoryStat>(
                        label: '占比',
                        flex: 4,
                        minWidth: 200,
                        cell: (context, row) => _ShareBar(
                          ratio: row.ratio.toDouble(),
                          color: palette[
                              categories.indexOf(row) % palette.length],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppLayout.sectionGap),
      ],
    );
  }
}

/// 占比进度条 + 百分比文字。
class _ShareBar extends StatelessWidget {
  const _ShareBar({required this.ratio, required this.color});

  final double ratio;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final double value = ratio.clamp(0.0, 1.0);
    return Row(
      children: <Widget>[
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 6,
              backgroundColor: AppColors.divider,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 44,
          child: Text(
            '${(value * 100).toStringAsFixed(1)}%',
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.amount,
    required this.color,
    this.flat = false,
  });

  final String label;
  final int amount;
  final Color color;

  /// 桌面档去掉主题自带的纵向 margin，让 4 张指标卡对齐。
  final bool flat;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: flat ? EdgeInsets.zero : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            Text(
              Money.formatCents(amount),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: color,
                    fontFeatures: const <FontFeature>[
                      FontFeature.tabularFigures(),
                    ],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavingRateCard extends StatelessWidget {
  const _SavingRateCard({required this.rate, this.flat = false});

  final double rate;
  final bool flat;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: flat ? EdgeInsets.zero : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('储蓄率', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Text(
              '${(rate * 100).round()}%',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.primary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
