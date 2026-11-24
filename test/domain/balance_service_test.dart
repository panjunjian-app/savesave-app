import 'package:decimal/decimal.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savesave/data/database.dart';
import 'package:savesave/domain/models/savings_goal.dart' as model;
import 'package:savesave/domain/services/balance_service.dart';

/// 结余、进度、里程碑与缓存一致性测试（使用内存 SQLite，不触碰真实数据）。
void main() {
  late AppDatabase db;
  late BalanceService service;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    service = BalanceService(db);
  });

  tearDown(() async {
    await db.close();
  });

  // 写入一笔账单：type 为 income/expense，金额为分。
  Future<void> addBill(
    String id,
    String ledgerId,
    String type,
    int amountCents,
    String billDate,
  ) async {
    await db.into(db.bills).insert(
          BillsCompanion.insert(
            id: id,
            ledgerId: ledgerId,
            categoryId: 'cat-1',
            type: type,
            amountCents: amountCents,
            billDate: billDate,
            createdAt: '2024-01-01T00:00:00.000Z',
            updatedAt: '2024-01-01T00:00:00.000Z',
          ),
        );
  }

  Future<void> addGoal(String goalId, int targetCents) async {
    await db.goalDao.save(
      model.SavingsGoal(
        id: goalId,
        userId: 'user-1',
        name: '测试目标',
        targetAmountCents: targetCents,
        deadline: null,
        icon: '',
        themeColor: '#1F6F5C',
        note: null,
        status: 'active',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ),
    );
  }

  // empty 是 getter，每次返回新实例，必须按字段断言而非引用比较。
  void expectEmptyProgress(GoalProgress p) {
    expect(p.balanceCents, 0);
    expect(p.ratio, Decimal.zero);
    expect(p.displayPercent, 0);
    expect(p.surplusCents, 0);
    expect(p.hint, '请先绑定账本');
    expect(p.isNegative, isFalse);
  }

  group('BalanceCache —— 依赖版本缓存', () {
    test('keyOf 对账本集合排序，集合顺序无关', () {
      expect(BalanceCache.keyOf(const {'b', 'a'}), 'a,b');
      expect(BalanceCache.keyOf(const {'a', 'b'}), 'a,b');
      expect(BalanceCache.keyOf(const {}), '');
    });

    test('putNet/getNet 命中，bumpLedger 后失效', () {
      final cache = BalanceCache();
      expect(cache.getNet(const {'l1'}), null);
      cache.putNet(const {'l1'}, 7000);
      expect(cache.getNet(const {'l1'}), 7000);

      cache.bumpLedger(const {'l1'});
      expect(cache.getNet(const {'l1'}), null);
    });

    test('只 bump 无关账本不影响其他缓存', () {
      final cache = BalanceCache();
      cache.putNet(const {'l1'}, 100);
      cache.putNet(const {'l2'}, 200);
      cache.bumpLedger(const {'l2'});
      expect(cache.getNet(const {'l1'}), 100);
      expect(cache.getNet(const {'l2'}), null);
    });

    test('进度缓存命中与失效', () {
      final cache = BalanceCache();
      final progress = GoalProgress(
        balanceCents: 500,
        ratio: Decimal.fromInt(1),
        displayPercent: 50,
        surplusCents: 0,
        isNegative: false,
      );
      cache.putProgress('g1', const {'l1'}, progress);
      expect(cache.getProgress('g1', const {'l1'}), same(progress));
      cache.bumpLedger(const {'l1'});
      expect(cache.getProgress('g1', const {'l1'}), null);
      cache.clear();
      expect(cache.getProgress('g1', const {'l1'}), null);
    });

    test('边界抽查：连续多次 bump 均能使缓存失效并重算', () {
      final cache = BalanceCache();
      for (var i = 1; i <= 3; i++) {
        cache.putNet(const {'l1'}, i * 100);
        expect(cache.getNet(const {'l1'}), i * 100);
        cache.bumpLedger(const {'l1'});
        expect(cache.getNet(const {'l1'}), null, reason: '第 $i 次 bump 后应失效');
      }
    });

    test('边界抽查：多账本集合任一成员 bump 即整体失效', () {
      final cache = BalanceCache();
      cache.putNet(const {'l1', 'l2'}, 900);
      expect(cache.getNet(const {'l1', 'l2'}), 900);
      cache.bumpLedger(const {'l1'});
      expect(cache.getNet(const {'l1', 'l2'}), null);
    });
  });

  group('BalanceService.netBalanceOf —— 累计净结余', () {
    test('空账本集合返回 0', () async {
      expect(await service.netBalanceOf(const {}), 0);
    });

    test('聚合多账本收入减支出', () async {
      await addBill('b1', 'l1', 'income', 10000, '2024-01-05');
      await addBill('b2', 'l1', 'expense', 3000, '2024-01-06');
      await addBill('b3', 'l2', 'income', 5000, '2024-01-07');
      expect(await service.netBalanceOf(const {'l1', 'l2'}), 12000);
    });

    test('支出大于收入得到负结余', () async {
      await addBill('b1', 'l1', 'expense', 5000, '2024-01-05');
      await addBill('b2', 'l1', 'income', 2000, '2024-01-06');
      expect(await service.netBalanceOf(const {'l1'}), -3000);
    });

    test('缓存命中返回旧值，invalidate 后重算', () async {
      await addBill('b1', 'l1', 'income', 10000, '2024-01-05');
      expect(await service.netBalanceOf(const {'l1'}), 10000);

      // 数据库已变化但未失效：应命中缓存。
      await addBill('b2', 'l1', 'income', 5000, '2024-01-06');
      expect(await service.netBalanceOf(const {'l1'}), 10000);

      service.invalidate(const {'l1'});
      expect(await service.netBalanceOf(const {'l1'}), 15000);
    });

    test('不同账本集合之间缓存互不串用', () async {
      await addBill('b1', 'l1', 'income', 100, '2024-01-05');
      await addBill('b2', 'l2', 'income', 200, '2024-01-05');
      expect(await service.netBalanceOf(const {'l1'}), 100);
      expect(await service.netBalanceOf(const {'l2'}), 200);
    });
  });

  group('BalanceService.breakdownOf —— 本月与累计', () {
    test('本月收支净额与累计净额分别统计', () async {
      final now = DateTime.now();
      final thisMonth =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-15';
      final prevDate = DateTime(now.year, now.month - 1, 15);
      final prevMonth =
          '${prevDate.year}-${prevDate.month.toString().padLeft(2, '0')}-15';

      await addBill('b1', 'l1', 'income', 10000, thisMonth);
      await addBill('b2', 'l1', 'expense', 2000, thisMonth);
      await addBill('b3', 'l1', 'income', 5000, prevMonth);

      final bd = await service.breakdownOf(const {'l1'});
      expect(bd.monthIncomeCents, 10000);
      expect(bd.monthExpenseCents, 2000);
      expect(bd.monthNetCents, 8000);
      expect(bd.cumulativeNetCents, 13000);
    });

    test('空账本得到全 0 明细', () async {
      final bd = await service.breakdownOf(const {});
      expect(bd.monthIncomeCents, 0);
      expect(bd.monthExpenseCents, 0);
      expect(bd.monthNetCents, 0);
      expect(bd.cumulativeNetCents, 0);
    });
  });

  group('BalanceService.progressOf —— 进度与钳制', () {
    test('目标不存在返回 empty（带绑定提示）', () async {
      final p = await service.progressOf('missing');
      expectEmptyProgress(p);
      expect(p.hint, '请先绑定账本');
      expect(p.displayPercent, 0);
    });

    test('目标存在但未绑定账本返回 empty', () async {
      await addGoal('g1', 10000);
      final p = await service.progressOf('g1');
      expectEmptyProgress(p);
    });

    test('目标金额非正返回 empty', () async {
      await addGoal('g1', 0);
      await db.goalDao.replaceBindings('g1', const {'l1'});
      await addBill('b1', 'l1', 'income', 5000, '2024-01-05');
      final p = await service.progressOf('g1');
      expectEmptyProgress(p);
    });

    test('正常进度：结余/目标精确比例', () async {
      await addGoal('g1', 10000);
      await db.goalDao.replaceBindings('g1', const {'l1'});
      await addBill('b1', 'l1', 'income', 7000, '2024-01-05');

      final p = await service.progressOf('g1');
      expect(p.balanceCents, 7000);
      expect(p.ratio.toDouble(), closeTo(0.7, 0.000001));
      expect(p.displayPercent, 70);
      expect(p.isNegative, isFalse);
      expect(p.surplusCents, 0);
      expect(p.hint, null);
    });

    test('结余与目标比例非有限小数时不应崩溃（如 1/3）', () async {
      await addGoal('g1', 300);
      await db.goalDao.replaceBindings('g1', const {'l1'});
      await addBill('b1', 'l1', 'income', 100, '2024-01-05');

      final p = await service.progressOf('g1');
      expect(p.displayPercent, 33);
      expect(p.balanceCents, 100);
    });

    test('边界抽查：2/7 等非有限小数比例不崩溃且百分比正确', () async {
      await addGoal('g1', 700);
      await db.goalDao.replaceBindings('g1', const {'l1'});
      await addBill('b1', 'l1', 'income', 200, '2024-01-05');

      final p = await service.progressOf('g1');
      expect(p.displayPercent, 29); // 200/700 * 100 = 28.571... → 29
      expect(p.ratio.toDouble(), closeTo(2 / 7, 0.0000001));
      expect(p.balanceCents, 200);
    });

    test('边界抽查：极小非有限小数比例与超大目标不溢出', () async {
      await addGoal('g1', 1000000003);
      await db.goalDao.replaceBindings('g1', const {'l1'});
      await addBill('b1', 'l1', 'income', 1, '2024-01-05');

      final p = await service.progressOf('g1');
      expect(p.displayPercent, 0);
      expect(p.balanceCents, 1);
      expect(p.isNegative, isFalse);
    });

    test('结余为负：比例与百分比钳制为 0，保留真实结余', () async {
      await addGoal('g1', 10000);
      await db.goalDao.replaceBindings('g1', const {'l1'});
      await addBill('b1', 'l1', 'expense', 1000, '2024-01-05');

      final p = await service.progressOf('g1');
      expect(p.balanceCents, -1000);
      expect(p.isNegative, isTrue);
      expect(p.ratio, Decimal.zero);
      expect(p.displayPercent, 0);
      expect(p.hint != null, isTrue);
    });

    test('结余为零视为无累计进度', () async {
      await addGoal('g1', 10000);
      await db.goalDao.replaceBindings('g1', const {'l1'});
      final p = await service.progressOf('g1');
      expect(p.isNegative, isTrue);
      expect(p.displayPercent, 0);
    });

    test('超额完成：百分比封顶 100 且记录超额分', () async {
      await addGoal('g1', 10000);
      await db.goalDao.replaceBindings('g1', const {'l1'});
      await addBill('b1', 'l1', 'income', 15000, '2024-01-05');

      final p = await service.progressOf('g1');
      expect(p.displayPercent, 100);
      expect(p.surplusCents, 5000);
      expect(p.isNegative, isFalse);
    });

    test('进度缓存：invalidate 后按新结余重算', () async {
      await addGoal('g1', 10000);
      await db.goalDao.replaceBindings('g1', const {'l1'});
      await addBill('b1', 'l1', 'income', 3000, '2024-01-05');
      expect((await service.progressOf('g1')).displayPercent, 30);

      await addBill('b2', 'l1', 'income', 3000, '2024-01-06');
      expect((await service.progressOf('g1')).displayPercent, 30); // 命中缓存

      service.invalidate(const {'l1'});
      expect((await service.progressOf('g1')).displayPercent, 60);
    });
  });

  group('BalanceService.checkMilestones —— 首次达标优先', () {
    GoalProgress progressAt(int percent) => GoalProgress(
          balanceCents: percent * 100,
          ratio: Decimal.fromInt(percent),
          displayPercent: percent,
          surplusCents: 0,
          isNegative: false,
        );

    test('30% 只记录 25% 里程碑且标记为首次', () async {
      final reached = await service.checkMilestones('g1', progressAt(30));
      expect(reached.length, 1);
      expect(reached.first.thresholdPct, 25);
      expect(reached.first.newlyReached, isTrue);
    });

    test('同一里程碑再次检查不再标记为首次', () async {
      await service.checkMilestones('g1', progressAt(30));
      final again = await service.checkMilestones('g1', progressAt(30));
      expect(again.single.newlyReached, isFalse);
    });

    test('100% 一次触发全部四档阈值', () async {
      final reached = await service.checkMilestones('g1', progressAt(100));
      expect(reached.map((e) => e.thresholdPct).toList(),
          BalanceService.milestoneThresholds);
      expect(reached.every((e) => e.newlyReached), isTrue);
    });

    test('低于 25% 不触发任何里程碑', () async {
      final reached = await service.checkMilestones('g1', progressAt(10));
      expect(reached, isEmpty);
    });

    test('进度回退不会删除已记录里程碑', () async {
      await service.checkMilestones('g1', progressAt(100));
      expect(await db.goalDao.reachedThresholds('g1'), hasLength(4));

      final regressed = await service.checkMilestones('g1', progressAt(30));
      expect(regressed.single.thresholdPct, 25);
      expect(regressed.single.newlyReached, isFalse);
      expect(await db.goalDao.reachedThresholds('g1'), hasLength(4));
    });
  });
}
