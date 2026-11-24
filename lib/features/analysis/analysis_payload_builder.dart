import '../../data/services/ai_client.dart';
import '../../domain/services/goal_accelerator.dart';
import '../../domain/services/statistics_service.dart';

/// Converts local authoritative statistics into a de-identified AI payload.
/// No number is left for the model to invent: all numbers are sent as already
/// computed cent values and the prompt forbids literal digits.
class AnalysisPayloadBuilder {
  const AnalysisPayloadBuilder();

  AnalysisPayload build({
    required StatsSnapshot stats,
    required GoalQuantization quantization,
    required bool includeNotes,
    required Map<String, String> ledgerAlias,
  }) {
    return AnalysisPayload(
      periodType: stats.range.type.name,
      periodLabel: stats.range.label,
      categories: stats.categories
          .map(
            (item) => CategorySummary(
              categoryKey: item.categoryId,
              categoryName: item.name,
              amountCents: item.amountCents,
              ratio: item.ratio,
              count: item.count,
            ),
          )
          .toList(growable: false),
      income: IncomeSummary(
        totalCents: stats.incomeCents,
        mainCategoryKey: '',
        mainCategoryName: '',
      ),
      expenseTotalCents: stats.expenseCents,
      savingRate: stats.savingRate,
      topExpenses: stats.topExpenses
          .map(
            (item) => ExpenseDetail(
              itemKey: item.billId,
              categoryKey: item.categoryId,
              categoryName: item.categoryName,
              amountCents: item.amountCents,
              date: item.date,
              maskedNote: item.maskedNote,
            ),
          )
          .toList(growable: false),
      goal: GoalContext(
        hasGoal: quantization.hasGoal,
        goalKey: quantization.hasGoal ? 'current' : null,
        targetCents: quantization.hasGoal ? quantization.targetCents : null,
        balanceCents: quantization.hasGoal ? quantization.balanceCents : null,
        remainingCents: quantization.hasGoal ? quantization.remainingCents : null,
        remainingMonths: quantization.hasGoal ? quantization.remainingMonths : null,
        monthlyGapCents: quantization.hasGoal ? quantization.monthlyGapCents : null,
        strategy: quantization.strategy,
      ),
      includeNotes: includeNotes,
      ledgerAlias: ledgerAlias,
    );
  }
}
