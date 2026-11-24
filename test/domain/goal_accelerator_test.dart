import 'package:flutter_test/flutter_test.dart';
import 'package:savesave/domain/services/goal_accelerator.dart';
import 'package:savesave/domain/services/period_range_resolver.dart';

/// 目标量化测试：三策略、月数 ceil、分整数取整、周期年均化。
void main() {
  const GoalAccelerator accelerator = GoalAccelerator();
  final DateTime now = DateTime(2024, 1, 1);

  // 统一构造量化输入，减少样例重复。
  GoalQuantization compute({
    bool hasGoal = true,
    int target = 100000,
    int balance = 0,
    int avg = 0,
    PeriodType period = PeriodType.month,
    String? deadline,
  }) {
    return accelerator.compute(
      hasGoal: hasGoal,
      targetCents: target,
      balanceCents: balance,
      averageNetPerPeriod: avg,
      periodType: period,
      deadline: deadline,
      now: now,
    );
  }

  group('toMonthlyCents —— 周期净额归一为月', () {
    test('月周期原值返回', () {
      expect(accelerator.toMonthlyCents(500, PeriodType.month), 500);
      expect(accelerator.toMonthlyCents(0, PeriodType.month), 0);
      expect(accelerator.toMonthlyCents(-300, PeriodType.month), -300);
    });

    test('周周期按 4.345 系数换算（Decimal 精确 round）', () {
      expect(accelerator.toMonthlyCents(1000, PeriodType.week), 4345);
      expect(accelerator.toMonthlyCents(2000, PeriodType.week), 8690);
    });

    test('季度能整除时正确', () {
      expect(accelerator.toMonthlyCents(3000, PeriodType.quarter), 1000);
    });

    test('季度不能整除时应四舍五入到分', () {
      expect(accelerator.toMonthlyCents(100, PeriodType.quarter), 33);
    });

    test('年能整除时正确', () {
      expect(accelerator.toMonthlyCents(1200, PeriodType.year), 100);
    });

    test('年不能整除时应四舍五入到分', () {
      expect(accelerator.toMonthlyCents(100, PeriodType.year), 8);
    });

    test('边界抽查：极小非整除金额四舍五入不崩溃', () {
      expect(accelerator.toMonthlyCents(1, PeriodType.quarter), 0); // 0.333→0
      expect(accelerator.toMonthlyCents(2, PeriodType.quarter), 1); // 0.667→1
      expect(accelerator.toMonthlyCents(1001, PeriodType.year), 83); // 83.417→83
      expect(accelerator.toMonthlyCents(1006, PeriodType.year), 84); // 83.833→84
    });

    test('边界抽查：负数非整除金额同样四舍五入', () {
      expect(accelerator.toMonthlyCents(-100, PeriodType.quarter), -33);
      expect(accelerator.toMonthlyCents(-1200, PeriodType.year), -100);
    });

    test('边界抽查：季度非整除均额归一后参与缺口计算', () {
      final q = compute(
        target: 100000,
        balance: 0,
        avg: 100,
        period: PeriodType.quarter,
      );
      expect(q.monthlyAvgNetCents, 33);
      expect(q.monthlyNeededCents, 16667);
      expect(q.monthlyGapCents, 16667 - 33);
    });
  });

  group('compute —— 三策略选择', () {
    test('无目标走 generic（即使结余为正）', () {
      final q = compute(hasGoal: false, balance: 50000);
      expect(q.strategy, GoalStrategy.generic);
      expect(q.hasGoal, isFalse);
    });

    test('有目标且结余为走 accelerate', () {
      final q = compute(hasGoal: true, balance: 50000);
      expect(q.strategy, GoalStrategy.accelerate);
    });

    test('有目标但结余为 0 或负走 buildPositive', () {
      expect(compute(balance: 0).strategy, GoalStrategy.buildPositive);
      expect(compute(balance: -1000).strategy, GoalStrategy.buildPositive);
    });

    test('结余恰为 0 不算正结余', () {
      final q = compute(balance: 0);
      expect(q.strategy, GoalStrategy.buildPositive);
    });
  });

  group('compute —— 剩余与目标量化', () {
    test('正常缺口：R=目标-结余，M=6，每月需补 ceil(R/M)', () {
      final q = compute(target: 100000, balance: 0, avg: 0);
      expect(q.remainingCents, 100000);
      expect(q.remainingMonths, 6);
      expect(q.monthlyNeededCents, 16667); // ceil(100000/6)
      expect(q.monthlyGapCents, 16667);
      expect(q.isMonthEstimate, isTrue);
    });

    test('分整数 ceil：100 分分 6 个月向上取整为 17', () {
      final q = compute(target: 100, balance: 0);
      expect(q.monthlyNeededCents, 17);
    });

    test('结余已达标：剩余 0，无需再存', () {
      final q = compute(target: 10000, balance: 15000);
      expect(q.remainingCents, 0);
      expect(q.monthlyNeededCents, 0);
      expect(q.monthlyGapCents, 0);
      expect(q.strategy, GoalStrategy.accelerate); // 结余仍为正
    });

    test('目标金额非正数时归一为 0', () {
      final q = compute(target: 0, balance: 0);
      expect(q.targetCents, 0);
      expect(q.remainingCents, 0);
      expect(q.monthlyNeededCents, 0);
    });

    test('月均净额已达要求时缺口为 0（不小于 0）', () {
      final q = compute(target: 100, balance: 0, avg: 200);
      expect(q.monthlyNeededCents, 17);
      expect(q.monthlyGapCents, 0);
    });

    test('周期净额先归一为月再算缺口', () {
      final weekly = compute(avg: 1000, period: PeriodType.week);
      expect(weekly.monthlyAvgNetCents, 4345); // 1000*4.345
      expect(weekly.monthlyGapCents, 16667 - 4345);

      final quarterly = compute(avg: 3000, period: PeriodType.quarter);
      expect(quarterly.monthlyAvgNetCents, 1000);
    });
  });

  group('compute —— 月数 ceil 与截止时间', () {
    test('无截止时间默认 6 个月并标记估算', () {
      final q = compute(deadline: null);
      expect(q.remainingMonths, 6);
      expect(q.isMonthEstimate, isTrue);
    });

    test('截止 60 天按 30 天/月 ceil 为 2 个月', () {
      // 2024 是闰年：1/1 -> 3/1 正好 60 天
      final q = compute(target: 1000, balance: 0, deadline: '2024-03-01');
      expect(q.remainingMonths, 2);
      expect(q.isMonthEstimate, isFalse);
      expect(q.monthlyNeededCents, 500); // ceil(1000/2)
    });

    test('截止 31 天 ceil 为 2 个月，30 天为 1 个月', () {
      // 2024-01-01 -> 2024-02-01 为 31 天（含 1 月 31 天）
      expect(compute(deadline: '2024-02-01').remainingMonths, 2);
      expect(compute(deadline: '2024-01-31').remainingMonths, 1);
    });

    test('截止今天或已过期按 1 个月', () {
      expect(compute(deadline: '2024-01-01').remainingMonths, 1);
      expect(compute(deadline: '2023-12-31').remainingMonths, 1);
    });

    test('非法截止串视为无截止', () {
      final q = compute(deadline: 'not-a-date');
      expect(q.remainingMonths, 6);
      expect(q.isMonthEstimate, isTrue);
    });
  });
}
