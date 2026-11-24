import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'analysis_report.freezed.dart';
part 'analysis_report.g.dart';

/// Cached AI analysis report. [reportJson] contains the final rendered report
/// (numbers already computed locally and placeholders already resolved).
@freezed
abstract class AnalysisReport with _$AnalysisReport {
  const AnalysisReport._();

  const factory AnalysisReport({
    required String id,
    required String scopePeriodType,
    required String scopePeriodLabel,
    required String scopeLedgerKey,
    required String scopeAnchorDate,
    required String reportJson,
    required String dataVersion,
    required String createdAt,
    required String expiresAt,
    @Default(false) bool isStale,
    String? goalKey,
    required String modelId,
    required String consentVersion,
  }) = _AnalysisReport;

  factory AnalysisReport.fromJson(Map<String, dynamic> json) =>
      _$AnalysisReportFromJson(json);

  Map<String, dynamic> get decodedJson {
    final decoded = jsonDecode(reportJson);
    return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
  }

  bool isExpired(DateTime nowUtc) => nowUtc.toUtc().isAfter(DateTime.parse(expiresAt));
}
