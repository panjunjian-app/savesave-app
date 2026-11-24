import 'package:flutter_test/flutter_test.dart';
import 'package:savesave/data/services/ai_client.dart';
import 'package:savesave/features/analysis/analysis_text_validator.dart';

/// AI 文本第三层防编造校验：数字拒收、占位符白名单、字段一致性、长度截断。
void main() {
  const AnalysisTextValidator validator = AnalysisTextValidator();

  // 构造一份完全合法的 AI 文案（不含任何字面数字）。
  AiAnalysisText makeText({
    String overview = '本期收入{{income}}，支出{{expense}}',
    List<OptimizeAdvice>? advices,
    List<UnnecessaryItem>? items,
    String goalComment = '目标{{goalTarget}}，已存{{goalBalance}}',
    String? noGoalSuggestion,
    List<String>? actions,
  }) {
    return AiAnalysisText(
      overviewComment: overview,
      optimizeAdvices: advices ?? [
        const OptimizeAdvice(categoryKey: 'cat-1', advice: '减少{{categoryAmount}}支出'),
      ],
      unnecessaryItems: items ?? [
        const UnnecessaryItem(
          itemKey: 'item-1',
          reason: '订阅续费',
          action: '取消订阅{{detailAmount}}',
        ),
      ],
      goalComment: goalComment,
      noGoalSuggestion: noGoalSuggestion,
      actionItems: actions ?? const ['坚持记账{{savingRate}}'],
    );
  }

  ValidatedAnalysisText runValidate(
    AiAnalysisText text, {
    Set<String> categories = const {'cat-1'},
    Set<String> items = const {'item-1'},
    bool hasGoal = true,
  }) {
    return validator.validate(
      text,
      allowedCategoryKeys: categories,
      allowedItemKeys: items,
      hasGoal: hasGoal,
    );
  }

  group('validate —— 合法文案', () {
    test('白名单占位符与合法 key 通过且无警告', () {
      final result = runValidate(makeText());
      expect(result.warnings, isEmpty);
      expect(result.text.overviewComment, contains('{{income}}'));
      expect(result.text.unnecessaryItems.single.reason, '订阅续费');
    });

    test('allowedCategoryKeys 为空时跳过分类 key 校验', () {
      final text = makeText(
        advices: const [OptimizeAdvice(categoryKey: 'unknown-cat', advice: '继续观察')],
      );
      expect(() => runValidate(text, categories: const {}), returnsNormally);
    });
  });

  group('validate —— 编造数字拒收', () {
    test('概览含阿拉伯数字抛 AnalysisValidationFailure', () {
      expect(
        () => runValidate(makeText(overview: '本期收入123元')),
        throwsA(isA<AnalysisValidationFailure>()),
      );
    });

    test('概览含全角数字同样拒收', () {
      expect(
        () => runValidate(makeText(overview: '本期收入１２３元')),
        throwsA(isA<AnalysisValidationFailure>()),
      );
    });

    test('行动建议含数字拒收', () {
      expect(
        () => runValidate(makeText(actions: const ['每月存100元'])),
        throwsA(isA<AnalysisValidationFailure>()),
      );
    });

    test('优化建议文案含数字拒收', () {
      final text = makeText(
        advices: const [OptimizeAdvice(categoryKey: 'cat-1', advice: '减少50%开销')],
      );
      expect(() => runValidate(text), throwsA(isA<AnalysisValidationFailure>()));
    });

    test('目标点评含字面数字应拒收（防编造第三层要求所有文案字段禁数字）', () {
      // 依据设计：AI 只出文案、数字一律本地渲染；goalComment 不得含字面数字。
      expect(
        () => runValidate(makeText(goalComment: '目标完成50%')),
        throwsA(isA<AnalysisValidationFailure>()),
      );
    });

    test('无目标建议含字面数字应拒收', () {
      final text = makeText(
        goalComment: '',
        noGoalSuggestion: '建议每月存100元',
      );
      expect(
        () => runValidate(text, hasGoal: false),
        throwsA(isA<AnalysisValidationFailure>()),
      );
    });

    test('边界抽查：目标点评与无目标建议含全角数字同样拒收', () {
      expect(
        () => runValidate(makeText(goalComment: '目标完成５０％')),
        throwsA(isA<AnalysisValidationFailure>()),
      );
      expect(
        () => runValidate(
          makeText(goalComment: '', noGoalSuggestion: '建议每月存１００元'),
          hasGoal: false,
        ),
        throwsA(isA<AnalysisValidationFailure>()),
      );
    });

    test('边界抽查：白名单占位符不会被误判为编造数字', () {
      final result = runValidate(
        makeText(
          goalComment: '目标{{goalTarget}}，剩余{{goalRemaining}}',
          noGoalSuggestion: '参考{{monthlyGap}}与{{monthlyAvgNet}}',
        ),
      );
      expect(result.warnings, isEmpty);
      expect(result.text.goalComment, contains('{{goalRemaining}}'));
    });
  });

  group('validate —— 占位符白名单', () {
    test('概览未知占位符拒收', () {
      expect(
        () => runValidate(makeText(overview: '数据{{hack}}')),
        throwsA(isA<AnalysisValidationFailure>()),
      );
    });

    test('目标点评未知占位符拒收', () {
      expect(
        () => runValidate(makeText(goalComment: '进度{{fake}}')),
        throwsA(isA<AnalysisValidationFailure>()),
      );
    });
  });

  group('validate —— key 一致性与字段完备性', () {
    test('AI 引用不存在的分类 key 拒收', () {
      final text = makeText(
        advices: const [OptimizeAdvice(categoryKey: 'ghost', advice: '减少开销')],
      );
      expect(() => runValidate(text), throwsA(isA<AnalysisValidationFailure>()));
    });

    test('AI 引用不存在的账单 key 拒收', () {
      final text = makeText(
        items: const [
          UnnecessaryItem(itemKey: 'ghost-item', reason: '其他', action: '取消'),
        ],
      );
      expect(() => runValidate(text), throwsA(isA<AnalysisValidationFailure>()));
    });

    test('非法 reason 归一为「其他」', () {
      final text = makeText(
        items: const [
          UnnecessaryItem(itemKey: 'item-1', reason: '乱七八糟', action: '取消订购'),
        ],
      );
      expect(runValidate(text).text.unnecessaryItems.single.reason, '其他');
    });

    test('有目标但缺少目标点评拒收', () {
      expect(
        () => runValidate(makeText(goalComment: '')),
        throwsA(isA<AnalysisValidationFailure>()),
      );
    });

    test('无目标却生成目标点评拒收', () {
      expect(
        () => runValidate(makeText(), hasGoal: false),
        throwsA(isA<AnalysisValidationFailure>()),
      );
    });
  });

  group('validate —— 长度截断与空项过滤', () {
    test('概览超过 160 字被截断并产生警告', () {
      final long = '分' * 161;
      final result = runValidate(makeText(overview: long));
      expect(result.text.overviewComment, hasLength(160));
      expect(result.warnings, contains('overviewComment 已按 160 字截断'));
    });

    test('行动项超过 40 字被截断', () {
      final result = runValidate(makeText(actions: ['做' * 41]));
      expect(result.text.actionItems.single, hasLength(40));
      expect(result.warnings, contains('actionItems 已按 40 字截断'));
    });

    test('空行动项被过滤掉', () {
      final result = runValidate(makeText(actions: const ['', '坚持记账']));
      expect(result.text.actionItems, ['坚持记账']);
    });
  });

  group('AnalysisTextValidator.fill —— 占位符本地渲染', () {
    test('白名单占位符替换为本地数值，未知占位符显示为破折号', () {
      final out = AnalysisTextValidator.fill(
        '收入{{income}} 支出{{expense}} 未知{{unknown}}',
        const <String, String>{'income': '100', 'expense': '50'},
      );
      expect(out, '收入100 支出50 未知—');
    });
  });
}
