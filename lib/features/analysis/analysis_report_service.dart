import 'dart:convert';

import 'package:dio/dio.dart';

import '../../core/config.dart';
import '../../core/money.dart';
import '../../core/uuid.dart';
import '../../data/dao/analysis_report_dao.dart';
import '../../data/services/ai_client.dart';
import '../../domain/models/analysis_report.dart';
import '../../domain/services/goal_accelerator.dart';
import '../../domain/services/statistics_service.dart';
import 'analysis_payload_builder.dart';
import 'analysis_text_validator.dart';

class AnalysisScope {
  const AnalysisScope({
    required this.periodType,
    required this.periodLabel,
    required this.ledgerKey,
    required this.anchorDate,
    required this.goalKey,
    required this.consentVersion,
  });

  final String periodType;
  final String periodLabel;
  final String ledgerKey;
  final String anchorDate;
  final String goalKey;
  final String consentVersion;
}

/// Orchestrates cache lookup, payload building, guarded AI call and rendering.
class AnalysisReportService {
  AnalysisReportService(
    this._client,
    this._dao, {
    AnalysisPayloadBuilder? builder,
    AnalysisTextValidator? validator,
  })  : _builder = builder ?? const AnalysisPayloadBuilder(),
        _validator = validator ?? const AnalysisTextValidator();

  final AiClient _client;
  final AnalysisReportDao _dao;
  final AnalysisPayloadBuilder _builder;
  final AnalysisTextValidator _validator;

  Future<AnalysisReport> generate({
    required AnalysisScope scope,
    required StatsSnapshot stats,
    required GoalQuantization quantization,
    required int dataRevision,
    required bool forceRefresh,
    required bool includeNotes,
    required Map<String, String> ledgerAlias,
    required CancelToken token,
  }) async {
    final dataVersion = _dataVersion(stats, quantization, dataRevision);
    if (!forceRefresh) {
      final cachedJson = await _dao.findLatestJson(
        periodType: scope.periodType,
        periodLabel: scope.periodLabel,
        ledgerKey: scope.ledgerKey,
      );
      if (cachedJson != null) {
        final decoded = _decode(cachedJson);
        if (decoded['dataVersion'] == dataVersion && decoded['isStale'] != true) {
          return AnalysisReport.fromJson(decoded);
        }
        await _dao.markStaleForScope(
          periodType: scope.periodType,
          periodLabel: scope.periodLabel,
          ledgerKey: scope.ledgerKey,
        );
      }
    }

    final payload = _builder.build(
      stats: stats,
      quantization: quantization,
      includeNotes: includeNotes,
      ledgerAlias: ledgerAlias,
    );
    final raw = await _client.analyzeFinances(payload: payload, token: token);
    final validated = _validator.validate(
      raw,
      allowedCategoryKeys: stats.categories.map((item) => item.categoryId).toSet(),
      allowedItemKeys: stats.topExpenses.map((item) => item.billId).toSet(),
      hasGoal: quantization.hasGoal,
    );

    final baseValues = _placeholders(stats, quantization);
    final filled = AiAnalysisText(
      overviewComment: AnalysisTextValidator.fill(
        validated.text.overviewComment,
        baseValues,
      ),
      optimizeAdvices: validated.text.optimizeAdvices.map((advice) {
        final category = stats.categories
            .where((item) => item.categoryId == advice.categoryKey)
            .firstOrNull;
        final values = <String, String>{
          ...baseValues,
          if (category != null) ...<String, String>{
            'categoryAmount': Money.formatCents(category.amountCents),
            'categoryRatio': '${(category.ratio.toDouble() * 100).round()}%',
            'categoryCount': '${category.count}',
          },
        };
        return OptimizeAdvice(
          categoryKey: advice.categoryKey,
          advice: AnalysisTextValidator.fill(advice.advice, values),
        );
      }).toList(growable: false),
      unnecessaryItems: validated.text.unnecessaryItems.map((item) {
        final detail = stats.topExpenses
            .where((entry) => entry.billId == item.itemKey)
            .firstOrNull;
        final values = <String, String>{
          ...baseValues,
          if (detail != null) 'detailAmount': Money.formatCents(detail.amountCents),
        };
        return UnnecessaryItem(
          itemKey: item.itemKey,
          reason: item.reason,
          action: AnalysisTextValidator.fill(item.action, values),
        );
      }).toList(growable: false),
      goalComment: AnalysisTextValidator.fill(validated.text.goalComment, baseValues),
      noGoalSuggestion: validated.text.noGoalSuggestion == null
          ? null
          : AnalysisTextValidator.fill(validated.text.noGoalSuggestion!, baseValues),
      actionItems: validated.text.actionItems
          .map((item) => AnalysisTextValidator.fill(item, baseValues))
          .toList(growable: false),
    );

    final now = DateTime.now().toUtc();
    final expiresAt = now.add(const Duration(days: 7));
    final id = Uuid.v4();
    final json = <String, dynamic>{
      'id': id,
      'scopePeriodType': scope.periodType,
      'scopePeriodLabel': scope.periodLabel,
      'scopeLedgerKey': scope.ledgerKey,
      'scopeAnchorDate': scope.anchorDate,
      'reportJson': '',
      'dataVersion': dataVersion,
      'createdAt': now.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'isStale': false,
      'goalKey': scope.goalKey,
      'modelId': AiConfig.modelId,
      'consentVersion': scope.consentVersion,
      'warnings': validated.warnings,
      'report': _textToJson(filled),
    };
    final reportJson = jsonEncode(json);
    json['reportJson'] = reportJson;
    await _dao.saveReport(
      id: id,
      periodType: scope.periodType,
      periodLabel: scope.periodLabel,
      ledgerKey: scope.ledgerKey,
      anchorDate: scope.anchorDate,
      reportJson: reportJson,
      dataVersion: dataVersion,
      createdAt: now.toIso8601String(),
      expiresAt: expiresAt.toIso8601String(),
      goalKey: scope.goalKey,
      modelId: AiConfig.modelId,
      consentVersion: scope.consentVersion,
    );
    return AnalysisReport.fromJson(json);
  }

  Map<String, dynamic> _decode(String reportJson) {
    final decoded = jsonDecode(reportJson);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid cached report');
    }
    return decoded;
  }

  String _dataVersion(
    StatsSnapshot stats,
    GoalQuantization quantization,
    int dataRevision,
  ) {
    return jsonEncode(<String, dynamic>{
      'revision': dataRevision,
      'range': stats.range.queryStart + stats.range.queryEnd,
      'income': stats.incomeCents,
      'expense': stats.expenseCents,
      'billCount': stats.billCount,
      'goalTarget': quantization.targetCents,
      'goalBalance': quantization.balanceCents,
      'strategy': quantization.strategy,
    });
  }

  Map<String, String> _placeholders(
    StatsSnapshot stats,
    GoalQuantization quantization,
  ) {
    return <String, String>{
      'income': Money.formatCents(stats.incomeCents),
      'expense': Money.formatCents(stats.expenseCents),
      'balance': Money.formatCents(stats.netCents),
      'savingRate': '${(stats.savingRate.toDouble() * 100).round()}%',
      'detailAmount': '',
      'goalTarget': quantization.hasGoal
          ? Money.formatCents(quantization.targetCents)
          : '—',
      'goalBalance': quantization.hasGoal
          ? Money.formatCents(quantization.balanceCents)
          : '—',
      'goalRemaining': quantization.hasGoal
          ? Money.formatCents(quantization.remainingCents)
          : '—',
      'remainingMonths': quantization.hasGoal
          ? '${quantization.remainingMonths} 个月'
          : '—',
      'monthlyGap': quantization.hasGoal
          ? Money.formatCents(quantization.monthlyGapCents)
          : '—',
      'monthlyAvgNet': quantization.hasGoal
          ? Money.formatCents(quantization.monthlyAvgNetCents)
          : '—',
      'deadline': quantization.deadline ?? '未设置',
    };
  }

  Map<String, dynamic> _textToJson(AiAnalysisText text) {
    return <String, dynamic>{
      'overviewComment': text.overviewComment,
      'optimizeAdvices': text.optimizeAdvices
          .map(
            (item) => <String, dynamic>{
              'categoryKey': item.categoryKey,
              'advice': item.advice,
            },
          )
          .toList(growable: false),
      'unnecessaryItems': text.unnecessaryItems
          .map(
            (item) => <String, dynamic>{
              'itemKey': item.itemKey,
              'reason': item.reason,
              'action': item.action,
            },
          )
          .toList(growable: false),
      'goalComment': text.goalComment,
      'noGoalSuggestion': text.noGoalSuggestion,
      'actionItems': text.actionItems,
    };
  }
}
