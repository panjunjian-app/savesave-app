import '../../data/services/ai_client.dart';

class AnalysisValidationFailure implements Exception {
  const AnalysisValidationFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

class ValidatedAnalysisText {
  const ValidatedAnalysisText({
    required this.text,
    required this.warnings,
  });

  final AiAnalysisText text;
  final List<String> warnings;
}

/// Layer 3 of the anti-fabrication strategy: the AI may only emit whitelisted
/// placeholders and real keys from the local payload. Literal digits are
/// rejected outright; overlong sentences are truncated with a warning.
class AnalysisTextValidator {
  const AnalysisTextValidator();

  static const Set<String> allowedPlaceholders = <String>{
    'income',
    'expense',
    'balance',
    'savingRate',
    'categoryAmount',
    'categoryRatio',
    'categoryCount',
    'detailAmount',
    'goalTarget',
    'goalBalance',
    'goalRemaining',
    'remainingMonths',
    'monthlyGap',
    'monthlyAvgNet',
    'deadline',
  };

  static const Set<String> allowedReasons = <String>{
    '订阅续费',
    '冲动消费',
    '低频高额',
    '重复支出',
    '其他',
  };

  static const int maxOverview = 160;
  static const int maxAdvice = 120;
  static const int maxAction = 80;
  static const int maxGoalComment = 200;
  static const int maxNoGoal = 120;
  static const int maxActionItem = 40;

  ValidatedAnalysisText validate(
    AiAnalysisText input, {
    required Set<String> allowedCategoryKeys,
    required Set<String> allowedItemKeys,
    required bool hasGoal,
  }) {
    final warnings = <String>[];
    _checkNoDigits(input.overviewComment, 'overviewComment');
    _checkPlaceholders(input.overviewComment);
    _checkNoDigits(input.goalComment, 'goalComment');
    _checkPlaceholders(input.goalComment);
    _checkNoDigits(input.noGoalSuggestion ?? '', 'noGoalSuggestion');
    _checkPlaceholders(input.noGoalSuggestion ?? '');
    for (final item in input.actionItems) {
      _checkNoDigits(item, 'actionItems');
      _checkPlaceholders(item);
    }

    for (final advice in input.optimizeAdvices) {
      _checkPlaceholders(advice.advice);
      _checkNoDigits(advice.advice, 'optimizeAdvices.advice');
      if (allowedCategoryKeys.isNotEmpty &&
          !allowedCategoryKeys.contains(advice.categoryKey)) {
        throw const AnalysisValidationFailure('AI 引用了不存在的分类');
      }
    }
    for (final item in input.unnecessaryItems) {
      _checkPlaceholders(item.reason);
      _checkPlaceholders(item.action);
      _checkNoDigits(item.action, 'unnecessaryItems.action');
      if (allowedItemKeys.isNotEmpty && !allowedItemKeys.contains(item.itemKey)) {
        throw const AnalysisValidationFailure('AI 引用了不存在的账单');
      }
    }

    if (hasGoal && input.goalComment.trim().isEmpty) {
      throw const AnalysisValidationFailure('缺少目标点评');
    }
    if (!hasGoal && input.goalComment.trim().isNotEmpty) {
      throw const AnalysisValidationFailure('无目标时不应生成目标点评');
    }

    final text = AiAnalysisText(
      overviewComment: _trim(input.overviewComment, maxOverview, 'overviewComment', warnings),
      optimizeAdvices: input.optimizeAdvices
          .map(
            (item) => OptimizeAdvice(
              categoryKey: item.categoryKey,
              advice: _trim(item.advice, maxAdvice, 'advice', warnings),
            ),
          )
          .toList(growable: false),
      unnecessaryItems: input.unnecessaryItems
          .map(
            (item) => UnnecessaryItem(
              itemKey: item.itemKey,
              reason: allowedReasons.contains(item.reason) ? item.reason : '其他',
              action: _trim(item.action, maxAction, 'action', warnings),
            ),
          )
          .toList(growable: false),
      goalComment: _trim(input.goalComment, maxGoalComment, 'goalComment', warnings),
      noGoalSuggestion: input.noGoalSuggestion == null
          ? null
          : _trim(input.noGoalSuggestion!, maxNoGoal, 'noGoalSuggestion', warnings),
      actionItems: input.actionItems
          .map((item) => _trim(item, maxActionItem, 'actionItems', warnings))
          .where((item) => item.isNotEmpty)
          .toList(growable: false),
    );
    return ValidatedAnalysisText(text: text, warnings: warnings);
  }

  /// Replaces whitelisted placeholders with locally computed display strings.
  static String fill(String text, Map<String, String> values) {
    return text.replaceAllMapped(
      RegExp(r'\{\{([A-Za-z]+)\}\}'),
      (match) => values[match.group(1)] ?? '—',
    );
  }

  static void _checkNoDigits(String text, String field) {
    if (RegExp(r'[0-9\uFF10-\uFF19]').hasMatch(text)) {
      throw AnalysisValidationFailure('$field 含有未授权的数字');
    }
  }

  static void _checkPlaceholders(String text) {
    for (final match in RegExp(r'\{\{([A-Za-z]+)\}\}').allMatches(text)) {
      final token = match.group(1) ?? '';
      if (!allowedPlaceholders.contains(token)) {
        throw AnalysisValidationFailure('未知占位符：$token');
      }
    }
  }

  static String _trim(
    String value,
    int limit,
    String field,
    List<String> warnings,
  ) {
    if (value.length <= limit) {
      return value;
    }
    warnings.add('$field 已按 $limit 字截断');
    return value.substring(0, limit);
  }
}
