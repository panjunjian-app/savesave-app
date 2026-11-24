// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analysis_report_dao.dart';

// ignore_for_file: type=lint
mixin _$AnalysisReportDaoMixin on DatabaseAccessor<AppDatabase> {
  $AiAnalysisReportsTable get aiAnalysisReports =>
      attachedDatabase.aiAnalysisReports;
  AnalysisReportDaoManager get managers => AnalysisReportDaoManager(this);
}

class AnalysisReportDaoManager {
  final _$AnalysisReportDaoMixin _db;
  AnalysisReportDaoManager(this._db);
  $$AiAnalysisReportsTableTableManager get aiAnalysisReports =>
      $$AiAnalysisReportsTableTableManager(
        _db.attachedDatabase,
        _db.aiAnalysisReports,
      );
}
