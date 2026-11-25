import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savesave/data/database.dart';
import 'package:savesave/data/migrations.dart';

/// v4 → v5 迁移守卫：存量数据不丢、user_id/updated_at 回填、重复执行幂等。
///
/// 说明：无法在测试里真实构造 v4 库文件，这里在已建 v5 结构的库上直接执行
/// migrateV4ToV5（列已存在 → 走幂等分支），重点覆盖回填逻辑与幂等性。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('复合主键表 user_id 从所属目标继承、空 updated_at 被回填', () async {
    const now = '2026-11-24T03:00:00.000Z';
    await db.into(db.savingsGoals).insert(
          SavingsGoalsCompanion.insert(
            id: 'goal-1',
            userId: 'u-local',
            name: '旅行基金',
            targetAmountCents: 100000,
            createdAt: now,
            updatedAt: now,
          ),
        );
    // v4 存量行：user_id 与 updated_at 均为空（v5 迁移前形态）
    await db.into(db.goalLedgerBindings).insert(
          GoalLedgerBindingsCompanion.insert(
            goalId: 'goal-1',
            ledgerId: 'ledger-1',
            userId: const Value(''),
            createdAt: now,
            updatedAt: const Value(''),
          ),
        );
    await db.into(db.categories).insert(
          CategoriesCompanion.insert(
            id: 'cat-1',
            userId: 'u-local',
            name: '餐饮',
            type: 'expense',
            updatedAt: const Value(''),
          ),
        );

    await migrateV4ToV5(db, db.createMigrator());

    final binding = await db.select(db.goalLedgerBindings).getSingle();
    expect(binding.userId, 'u-local'); // 从 savings_goals 继承
    expect(binding.updatedAt, isNotEmpty); // 空时间戳已回填

    final category = await db.select(db.categories).getSingle();
    expect(category.updatedAt, isNotEmpty);

    // 存量业务数据不丢
    expect((await db.select(db.savingsGoals).get()).single.id, 'goal-1');
  });

  test('重复执行迁移幂等（不移除数据、不报错）', () async {
    const now = '2026-11-24T03:00:00.000Z';
    await db.into(db.savingsGoals).insert(
          SavingsGoalsCompanion.insert(
            id: 'goal-1',
            userId: 'u-local',
            name: '旅行基金',
            targetAmountCents: 100000,
            createdAt: now,
            updatedAt: now,
          ),
        );

    await migrateV4ToV5(db, db.createMigrator());
    await migrateV4ToV5(db, db.createMigrator());

    expect((await db.select(db.savingsGoals).get()).single.name, '旅行基金');
    final watermarkTables = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'sync_states'")
        .get();
    expect(watermarkTables, hasLength(1)); // 水位表建好且唯一
  });
}
