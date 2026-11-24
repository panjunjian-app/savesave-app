import 'package:flutter_test/flutter_test.dart';
import 'package:savesave/domain/services/period_range_resolver.dart';

/// 时间边界测试：四个自然周期维度、offset 偏移、闰年、包含判定。
/// 全部使用本地时区构造与格式化，符合「本地日历日期」约定。
void main() {
  const PeriodRangeResolver resolver = PeriodRangeResolver();

  group('周周期（周一 ~ 周日）', () {
    test('周三锚点归到本周一~周日', () {
      final r = resolver.resolve(PeriodType.week, DateTime(2024, 1, 3));
      expect(r.queryStart, '2024-01-01');
      expect(r.queryEnd, '2024-01-07');
      expect(r.label, '2024-W01');
    });

    test('周日锚点仍归本周（不跨到下周）', () {
      final r = resolver.resolve(PeriodType.week, DateTime(2024, 1, 7));
      expect(r.queryStart, '2024-01-01');
      expect(r.queryEnd, '2024-01-07');
    });

    test('周一锚点取本周', () {
      final r = resolver.resolve(PeriodType.week, DateTime(2024, 1, 1));
      expect(r.queryStart, '2024-01-01');
      expect(r.queryEnd, '2024-01-07');
    });

    test('offset 正偏移取下一周', () {
      final r = resolver.resolve(PeriodType.week, DateTime(2024, 1, 3), offset: 1);
      expect(r.queryStart, '2024-01-08');
      expect(r.queryEnd, '2024-01-14');
    });

    test('offset 负偏移跨年', () {
      final r = resolver.resolve(PeriodType.week, DateTime(2024, 1, 3), offset: -1);
      expect(r.queryStart, '2023-12-25');
      expect(r.queryEnd, '2023-12-31');
    });
  });

  group('月周期', () {
    test('闰年二月取到 29 日', () {
      final r = resolver.resolve(PeriodType.month, DateTime(2024, 2, 15));
      expect(r.queryStart, '2024-02-01');
      expect(r.queryEnd, '2024-02-29');
      expect(r.label, '2024-02');
    });

    test('平年二月取到 28 日', () {
      final r = resolver.resolve(PeriodType.month, DateTime(2023, 2, 15));
      expect(r.queryStart, '2023-02-01');
      expect(r.queryEnd, '2023-02-28');
    });

    test('offset 正偏移跨到明年一月', () {
      final r = resolver.resolve(PeriodType.month, DateTime(2024, 12, 15), offset: 1);
      expect(r.queryStart, '2025-01-01');
      expect(r.queryEnd, '2025-01-31');
      expect(r.label, '2025-01');
    });

    test('offset 负偏移跨到去年十二月', () {
      final r = resolver.resolve(PeriodType.month, DateTime(2024, 1, 15), offset: -1);
      expect(r.queryStart, '2023-12-01');
      expect(r.queryEnd, '2023-12-31');
    });
  });

  group('季度周期', () {
    test('Q1 边界 1/1~3/31', () {
      final r = resolver.resolve(PeriodType.quarter, DateTime(2024, 2, 10));
      expect(r.queryStart, '2024-01-01');
      expect(r.queryEnd, '2024-03-31');
      expect(r.label, '2024-Q1');
    });

    test('Q2 / Q3 / Q4 边界', () {
      final q2 = resolver.resolve(PeriodType.quarter, DateTime(2024, 5, 1));
      expect(q2.queryStart, '2024-04-01');
      expect(q2.queryEnd, '2024-06-30');
      expect(q2.label, '2024-Q2');

      final q3 = resolver.resolve(PeriodType.quarter, DateTime(2024, 8, 1));
      expect(q3.queryStart, '2024-07-01');
      expect(q3.queryEnd, '2024-09-30');

      final q4 = resolver.resolve(PeriodType.quarter, DateTime(2024, 11, 1));
      expect(q4.queryStart, '2024-10-01');
      expect(q4.queryEnd, '2024-12-31');
    });

    test('offset 正偏移从 Q4 跨到明年 Q1', () {
      final r = resolver.resolve(PeriodType.quarter, DateTime(2024, 11, 1), offset: 1);
      expect(r.queryStart, '2025-01-01');
      expect(r.queryEnd, '2025-03-31');
      expect(r.label, '2025-Q1');
    });

    test('offset 负偏移从 Q1 跨到去年 Q4', () {
      final r = resolver.resolve(PeriodType.quarter, DateTime(2024, 2, 1), offset: -1);
      expect(r.queryStart, '2023-10-01');
      expect(r.queryEnd, '2023-12-31');
      expect(r.label, '2023-Q4');
    });
  });

  group('年周期', () {
    test('自然年 1/1~12/31', () {
      final r = resolver.resolve(PeriodType.year, DateTime(2024, 6, 15));
      expect(r.queryStart, '2024-01-01');
      expect(r.queryEnd, '2024-12-31');
      expect(r.label, '2024');
    });

    test('offset 正负偏移', () {
      expect(
        resolver.resolve(PeriodType.year, DateTime(2024, 6, 15), offset: 1).queryStart,
        '2025-01-01',
      );
      expect(
        resolver.resolve(PeriodType.year, DateTime(2024, 6, 15), offset: -1).queryEnd,
        '2023-12-31',
      );
    });
  });

  group('containsLocalDate 与查询串', () {
    test('起止日均包含，带时分秒按自然日归一', () {
      final r = resolver.resolve(PeriodType.week, DateTime(2024, 1, 3));
      expect(r.containsLocalDate(DateTime(2024, 1, 1)), isTrue);
      expect(r.containsLocalDate(DateTime(2024, 1, 1, 23, 59, 59)), isTrue);
      expect(r.containsLocalDate(DateTime(2024, 1, 7)), isTrue);
      expect(r.containsLocalDate(DateTime(2024, 1, 7, 23, 59)), isTrue);
    });

    test('范围外日期返回 false', () {
      final r = resolver.resolve(PeriodType.week, DateTime(2024, 1, 3));
      expect(r.containsLocalDate(DateTime(2023, 12, 31)), isFalse);
      expect(r.containsLocalDate(DateTime(2024, 1, 8)), isFalse);
    });

    test('toQueryStart / toQueryEnd 与属性一致', () {
      final r = resolver.resolve(PeriodType.month, DateTime(2024, 2, 1));
      expect(resolver.toQueryStart(r), r.queryStart);
      expect(resolver.toQueryEnd(r), r.queryEnd);
    });
  });
}
