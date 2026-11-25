import 'package:drift/drift.dart';

import '../database.dart';
import '../tables.dart';

part 'analysis_report_dao.g.dart';

/// CRUD and scope queries for cached AI analysis reports.
@DriftAccessor(tables: [AiAnalysisReports])
class AnalysisReportDao extends DatabaseAccessor<AppDatabase>
    with _$AnalysisReportDaoMixin {
  AnalysisReportDao(super.attachedDatabase);

  Stream<String?> watchLatestJson({
    required String periodType,
    required String periodLabel,
    required String ledgerKey,
  }) {
    return _scopeQuery(
      periodType: periodType,
      periodLabel: periodLabel,
      ledgerKey: ledgerKey,
    )
        .watch()
        .map((rows) => rows.isEmpty ? null : rows.first.reportJson);
  }

  Future<String?> findLatestJson({
    required String periodType,
    required String periodLabel,
    required String ledgerKey,
  }) async {
    final rows = await _scopeQuery(
      periodType: periodType,
      periodLabel: periodLabel,
      ledgerKey: ledgerKey,
    ).get();
    return rows.isEmpty ? null : rows.first.reportJson;
  }

  Future<void> saveReport({
    required String id,
    required String periodType,
    required String periodLabel,
    required String ledgerKey,
    required String anchorDate,
    required String reportJson,
    required String dataVersion,
    required String createdAt,
    required String expiresAt,
    required String goalKey,
    required String modelId,
    required String consentVersion,
  }) async {
    await into(aiAnalysisReports).insert(
          AiAnalysisReportsCompanion.insert(
            id: id,
            scopePeriodType: periodType,
            scopePeriodLabel: periodLabel,
            scopeLedgerKey: ledgerKey,
            scopeAnchorDate: anchorDate,
            reportJson: reportJson,
            dataVersion: dataVersion,
            createdAt: createdAt,
            // v5：updatedAt 供脏数据扫描与 LWW 使用（记录不可变，仅标记可变）。
            updatedAt: Value(createdAt),
            expiresAt: expiresAt,
            isStale: const Value(false),
            goalKey: Value(goalKey.isEmpty ? null : goalKey),
            modelId: modelId,
            consentVersion: consentVersion,
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  Future<int> markStaleForScope({
    required String periodType,
    required String periodLabel,
    required String ledgerKey,
  }) {
    return (update(aiAnalysisReports)
          ..where((row) =>
              row.scopePeriodType.equals(periodType) &
              row.scopePeriodLabel.equals(periodLabel) &
              row.scopeLedgerKey.equals(ledgerKey)))
        .write(AiAnalysisReportsCompanion(
      isStale: const Value(true),
      // 标记变化也要进同步：updated_at 前推才能被脏扫描捕获。
      updatedAt: Value(DateTime.now().toUtc().toIso8601String()),
    ));
  }

  Future<int> markStaleForGoal(String goalKey) {
    return (update(aiAnalysisReports)..where((row) => row.goalKey.equals(goalKey)))
        .write(AiAnalysisReportsCompanion(
      isStale: const Value(true),
      updatedAt: Value(DateTime.now().toUtc().toIso8601String()),
    ));
  }

  Future<int> markAllStale() {
    return update(aiAnalysisReports).write(AiAnalysisReportsCompanion(
      isStale: const Value(true),
      updatedAt: Value(DateTime.now().toUtc().toIso8601String()),
    ));
  }

  /// Soft-expiry: reports older than [expiresAt] are flagged but never deleted.
  Future<int> markExpiredStale(String nowIso) {
    return (update(aiAnalysisReports)
          ..where((row) =>
              row.expiresAt.isSmallerThanValue(nowIso) & row.isStale.equals(false)))
        .write(AiAnalysisReportsCompanion(
      isStale: const Value(true),
      updatedAt: Value(DateTime.now().toUtc().toIso8601String()),
    ));
  }

  Future<int> deleteAll() => delete(aiAnalysisReports).go();

  Future<int> deleteOlderThan(String cutoffIso) {
    return (delete(aiAnalysisReports)
          ..where((row) => row.createdAt.isSmallerThanValue(cutoffIso)))
        .go();
  }

  SimpleSelectStatement<AiAnalysisReports, AiAnalysisReport> _scopeQuery({
    required String periodType,
    required String periodLabel,
    required String ledgerKey,
  }) {
    return select(aiAnalysisReports)
      ..where((row) =>
          row.scopePeriodType.equals(periodType) &
          row.scopePeriodLabel.equals(periodLabel) &
          row.scopeLedgerKey.equals(ledgerKey) &
          row.isStale.equals(false) &
          row.isDeleted.equals(false))
      ..orderBy([(row) => OrderingTerm.desc(row.createdAt)])
      ..limit(1);
  }
}
