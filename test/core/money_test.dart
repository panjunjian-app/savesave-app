import 'package:flutter_test/flutter_test.dart';
import 'package:savesave/core/config.dart';
import 'package:savesave/core/money.dart';

/// 金额核心逻辑测试：一律以「分」为单位的整数，禁止浮点误差。
void main() {
  group('Money.parseYuanToCents —— 元字符串转分', () {
    test('普通小数金额精确转分', () {
      // 安排 + 行动 + 断言
      expect(Money.parseYuanToCents('123.45'), 12345);
      expect(Money.parseYuanToCents('0.01'), 1);
      expect(Money.parseYuanToCents('0.1'), 10);
      expect(Money.parseYuanToCents('0'), 0);
    });

    test('大额金额无浮点误差（超过 double 精确表示范围）', () {
      // 987654321.01 若走 double 会出现分位丢失，Decimal 必须精确。
      expect(Money.parseYuanToCents('987654321.01'), 98765432101);
      expect(Money.parseYuanToCents('123456789.99'), 12345678999);
    });

    test('货币符号与千分位（半角逗号）被清理', () {
      expect(Money.parseYuanToCents('¥1,234.50'), 123450);
      expect(Money.parseYuanToCents('￥12,345.60'), 1234560);
    });

    test('中文逗号、元后缀与空格被清理', () {
      expect(Money.parseYuanToCents('￥1，234.50元'), 123450);
      expect(Money.parseYuanToCents('1 234.50'), 123450);
      expect(Money.parseYuanToCents('100元'), 10000);
    });

    test('快捷单位 万 / 千 / 百 正确换算', () {
      expect(Money.parseYuanToCents('10万'), 10000000); // 10万元 = 10,000,000分
      expect(Money.parseYuanToCents('1.5万'), 1500000);
      expect(Money.parseYuanToCents('2千'), 200000);
      expect(Money.parseYuanToCents('3百'), 30000);
    });

    test('负数金额（支出场景）保持符号', () {
      expect(Money.parseYuanToCents('-12.34'), -1234);
      expect(Money.parseYuanToCents('-10万'), -10000000);
    });

    test('空串、纯符号、非数字抛出 FormatException', () {
      expect(() => Money.parseYuanToCents(''), throwsFormatException);
      expect(() => Money.parseYuanToCents('   '), throwsFormatException);
      expect(() => Money.parseYuanToCents('abc'), throwsFormatException);
      expect(() => Money.parseYuanToCents('万'), throwsFormatException);
      expect(() => Money.parseYuanToCents('1.2.3'), throwsFormatException);
    });

    test('恰好等于 15 位保护上限时通过', () {
      // maxAmountCents = 999999999999999（分）
      expect(
        Money.parseYuanToCents('9999999999999.99'),
        AppConfig.maxAmountCents,
      );
    });

    test('超过 15 位保护上限抛出 ArgumentError', () {
      expect(
        () => Money.parseYuanToCents('10000000000000.00'),
        throwsArgumentError,
      );
      expect(() => Money.parseYuanToCents('999999999999999万'), throwsArgumentError);
    });
  });

  group('Money.enforceLimit —— 技术保护上限', () {
    test('上限内原值返回', () {
      expect(Money.enforceLimit(0), 0);
      expect(Money.enforceLimit(12345), 12345);
      expect(Money.enforceLimit(AppConfig.maxAmountCents), AppConfig.maxAmountCents);
      expect(Money.enforceLimit(-AppConfig.maxAmountCents), -AppConfig.maxAmountCents);
    });

    test('越界（正/负）抛出 ArgumentError', () {
      expect(() => Money.enforceLimit(AppConfig.maxAmountCents + 1), throwsArgumentError);
      expect(() => Money.enforceLimit(-AppConfig.maxAmountCents - 1), throwsArgumentError);
    });
  });

  group('Money.formatCents —— 本地化展示', () {
    test('格式化带有货币符号与千分位', () {
      expect(Money.formatCents(123450), contains('1,234.50'));
      expect(Money.formatCents(123450), contains('¥'));
      expect(Money.formatCents(0), contains('0.00'));
    });

    test('负数格式化保留绝对值数字', () {
      expect(Money.formatCents(-123450), contains('1,234.50'));
    });
  });

  group('Money.plainCents —— 纯数字分串', () {
    test('正数与零', () {
      expect(Money.plainCents(123450), '1234.50');
      expect(Money.plainCents(100), '1.00');
      expect(Money.plainCents(5), '0.05');
      expect(Money.plainCents(0), '0.00');
    });

    test('负数与补零', () {
      expect(Money.plainCents(-123450), '-1234.50');
      expect(Money.plainCents(-5), '-0.05');
      expect(Money.plainCents(1020), '10.20');
    });

    test('encodeCents 输出 JSON 安全字符串', () {
      expect(Money.encodeCents(123450), '"1234.50"');
    });
  });
}
