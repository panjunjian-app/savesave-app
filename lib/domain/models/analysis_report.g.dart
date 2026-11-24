// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analysis_report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AnalysisReport _$AnalysisReportFromJson(Map<String, dynamic> json) =>
    _AnalysisReport(
      id: json['id'] as String,
      scopePeriodType: json['scopePeriodType'] as String,
      scopePeriodLabel: json['scopePeriodLabel'] as String,
      scopeLedgerKey: json['scopeLedgerKey'] as String,
      scopeAnchorDate: json['scopeAnchorDate'] as String,
      reportJson: json['reportJson'] as String,
      dataVersion: json['dataVersion'] as String,
      createdAt: json['createdAt'] as String,
      expiresAt: json['expiresAt'] as String,
      isStale: json['isStale'] as bool? ?? false,
      goalKey: json['goalKey'] as String?,
      modelId: json['modelId'] as String,
      consentVersion: json['consentVersion'] as String,
    );

Map<String, dynamic> _$AnalysisReportToJson(_AnalysisReport instance) =>
    <String, dynamic>{
      'id': instance.id,
      'scopePeriodType': instance.scopePeriodType,
      'scopePeriodLabel': instance.scopePeriodLabel,
      'scopeLedgerKey': instance.scopeLedgerKey,
      'scopeAnchorDate': instance.scopeAnchorDate,
      'reportJson': instance.reportJson,
      'dataVersion': instance.dataVersion,
      'createdAt': instance.createdAt,
      'expiresAt': instance.expiresAt,
      'isStale': instance.isStale,
      'goalKey': instance.goalKey,
      'modelId': instance.modelId,
      'consentVersion': instance.consentVersion,
    };
