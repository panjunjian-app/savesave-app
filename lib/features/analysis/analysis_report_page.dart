import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme.dart';
import '../../data/services/ai_client.dart';
import '../../domain/services/period_range_resolver.dart';
import '../../state/providers.dart';
import '../common/empty_view.dart';
import 'analysis_report_service.dart';

class AnalysisReportPage extends ConsumerStatefulWidget {
  const AnalysisReportPage({super.key});

  @override
  ConsumerState<AnalysisReportPage> createState() => _AnalysisReportPageState();
}

class _AnalysisReportPageState extends ConsumerState<AnalysisReportPage> {
  PeriodType _periodType = PeriodType.month;
  int _offset = 0;
  bool _loading = false;
  String? _error;
  bool _consented = false;
  bool _includeNotes = false;

  @override
  void initState() {
    super.initState();
    _loadConsent();
  }

  Future<void> _loadConsent() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(
        () => _consented = prefs.getBool(AiPrefsKeys.analysisConsented) ?? false,
      );
    }
  }

  Future<void> _toggleConsent(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AiPrefsKeys.analysisConsented, value);
    if (mounted) {
      setState(() => _consented = value);
    }
  }

  Future<void> _generate() async {
    final available = await ref.read(aiAvailabilityProvider.future);
    if (!available) {
      if (mounted) {
        context.go('/settings/ai-config');
      }
      return;
    }
    final snapshot = await ref.read(
      statsProvider(
        (
          ledgerKey: ref.read(selectedLedgerIdProvider),
          periodType: _periodType,
          offset: _offset,
        ),
      ).future,
    );
    if (snapshot.billCount == 0) {
      setState(() => _error = '该周期暂无账单，无法生成分析');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    final token = CancelToken();
    try {
      final goal = ref.read(focusedGoalProvider).valueOrNull;
      final balanceCents = goal == null
          ? 0
          : (await ref.read(goalProgressProvider(goal.id).future)).balanceCents;
      final quantization = ref.read(goalAcceleratorProvider).compute(
            hasGoal: goal != null,
            targetCents: goal?.targetAmountCents ?? 0,
            balanceCents: balanceCents,
            deadline: goal?.deadline,
            averageNetPerPeriod: snapshot.netCents,
            periodType: _periodType,
          );
      final ledgerAlias = <String, String>{
        for (final ledger in ref.read(ledgersProvider).valueOrNull ?? const [])
          ledger.id: ledger.name,
      };
      await ref.read(analysisReportServiceProvider).generate(
            scope: AnalysisScope(
              periodType: snapshot.range.type.name,
              periodLabel: snapshot.range.label,
              ledgerKey: ref.read(selectedLedgerIdProvider),
              anchorDate: snapshot.range.queryStart,
              goalKey: goal?.id ?? '',
              consentVersion: 'v2.1',
            ),
            stats: snapshot,
            quantization: quantization,
            dataRevision: ref.read(dataRevisionProvider),
            forceRefresh: false,
            includeNotes: _includeNotes,
            ledgerAlias: ledgerAlias,
            token: token,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('分析报告已生成')),
        );
      }
    } on AiCancelledException {
      if (mounted) {
        setState(() => _error = '已取消生成');
      }
    } on AiFailure catch (failure) {
      if (mounted) {
        setState(() => _error = failure.message);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _error = '生成失败：$error');
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ledgerKey = ref.watch(selectedLedgerIdProvider);
    final range = ref.watch(periodRangeResolverProvider).resolve(
          _periodType,
          DateTime.now(),
          offset: _offset,
        );
    final reportAsync = ref.watch(
      latestAnalysisReportProvider(
        (
          periodType: _periodType.name,
          periodLabel: range.label,
          ledgerKey: ledgerKey,
        ),
      ),
    );
    final availabilityAsync = ref.watch(aiAvailabilityProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 收支分析报告'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.go('/settings/ai-config'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'AI 只负责点评与建议，所有金额、占比与进度均由本机精确计算后填入。',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('同意发送脱敏统计数据'),
                    subtitle: const Text('可随时在设置中撤回'),
                    value: _consented,
                    onChanged: _toggleConsent,
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('附带脱敏备注'),
                    subtitle: const Text('数字与字母将替换为 *'),
                    value: _includeNotes,
                    onChanged: (value) => setState(() => _includeNotes = value),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: DropdownButtonFormField<PeriodType>(
                  initialValue: _periodType,
                  decoration: const InputDecoration(labelText: '分析周期'),
                  items: PeriodType.values
                      .map(
                        (type) => DropdownMenuItem<PeriodType>(
                          value: type,
                          child: Text(_periodLabel(type)),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _periodType = value;
                        _offset = 0;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => setState(() => _offset--),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => setState(() => _offset++),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${range.label} · ${range.queryStart} 至 ${range.queryEnd}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          availabilityAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const Text('AI 状态检查失败'),
            data: (available) => FilledButton.icon(
              onPressed: _loading || !_consented || !available ? null : _generate,
              icon: _loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(
                !available
                    ? '请先配置并验证 AI Key'
                    : !_consented
                        ? '请先同意数据使用说明'
                        : _loading
                            ? '生成中...'
                            : '生成本周期报告',
              ),
            ),
          ),
          if (_error != null) ...<Widget>[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: AppColors.danger)),
          ],
          const SizedBox(height: 24),
          reportAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text('读取报告失败：$error'),
            data: (json) {
              if (json == null || json.isEmpty) {
                return const EmptyView(
                  icon: Icons.article_outlined,
                  title: '还没有分析报告',
                  message: '选择周期并点击生成，AI 将给出简短点评与建议。',
                );
              }
              final decoded = jsonDecode(json) as Map<String, dynamic>;
              final report = decoded['report'] as Map<String, dynamic>? ??
                  <String, dynamic>{};
              return _ReportView(report: report, decoded: decoded);
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  static String _periodLabel(PeriodType type) {
    return switch (type) {
      PeriodType.week => '本周',
      PeriodType.month => '本月',
      PeriodType.quarter => '本季',
      PeriodType.year => '本年',
    };
  }
}

class _ReportView extends StatelessWidget {
  const _ReportView({required this.report, required this.decoded});

  final Map<String, dynamic> report;
  final Map<String, dynamic> decoded;

  @override
  Widget build(BuildContext context) {
    final overall = report['overviewComment'] as String? ?? '';
    final goalComment = report['goalComment'] as String? ?? '';
    final noGoal = report['noGoalSuggestion'] as String? ?? '';
    final advices = (report['optimizeAdvices'] as List<dynamic>? ?? [])
        .whereType<Map>()
        .toList(growable: false);
    final items = (report['unnecessaryItems'] as List<dynamic>? ?? [])
        .whereType<Map>()
        .toList(growable: false);
    final actions = (report['actionItems'] as List<dynamic>? ?? [])
        .map((item) => item.toString())
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (decoded['isStale'] == true)
          const Card(
            color: AppColors.goldLight,
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Text('数据已变化，建议重新生成报告'),
            ),
          ),
        _ReportSection(title: '总体点评', content: overall),
        if (goalComment.isNotEmpty)
          _ReportSection(title: '目标进度点评', content: goalComment),
        if (noGoal.isNotEmpty)
          _ReportSection(title: '目标建议', content: noGoal),
        if (advices.isNotEmpty)
          _ReportListSection(
            title: '优化建议',
            items: advices
                .map(
                  (item) => item['advice']?.toString() ?? '',
                )
                .toList(growable: false),
          ),
        if (items.isNotEmpty)
          _ReportListSection(
            title: '可考虑缩减',
            items: items
                .map(
                  (item) =>
                      '${item['reason'] ?? '其他'}：${item['action'] ?? ''}',
                )
                .toList(growable: false),
          ),
        if (actions.isNotEmpty)
          _ReportListSection(title: '下一步行动', items: actions),
      ],
    );
  }
}

class _ReportSection extends StatelessWidget {
  const _ReportSection({required this.title, required this.content});

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(content),
          ],
        ),
      ),
    );
  }
}

class _ReportListSection extends StatelessWidget {
  const _ReportListSection({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...items.where((item) => item.isNotEmpty).map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text('• ', style: TextStyle(color: AppColors.gold)),
                        Expanded(child: Text(item)),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
