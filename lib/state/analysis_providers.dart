import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/analysis/analysis_report_service.dart';
import 'core_providers.dart';

final analysisReportServiceProvider = Provider<AnalysisReportService>((ref) {
  return AnalysisReportService(
    ref.watch(aiClientProvider),
    ref.watch(analysisReportDaoProvider),
  );
});

final latestAnalysisReportProvider = StreamProvider.family<
    String?,
    ({String periodType, String periodLabel, String ledgerKey})>((ref, key) {
  return ref.watch(analysisReportDaoProvider).watchLatestJson(
        periodType: key.periodType,
        periodLabel: key.periodLabel,
        ledgerKey: key.ledgerKey,
      );
});
