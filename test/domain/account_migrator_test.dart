import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savesave/core/api_client.dart';
import 'package:savesave/data/database.dart';
import 'package:savesave/data/sync/account_migrator.dart';
import 'package:savesave/data/sync/sync_dao.dart';
import 'package:savesave/data/sync/sync_service.dart';

/// 可控同步通道：记录推送行；可配置首次 push 失败（模拟断网/中断）。
class _FakeSyncApi implements SyncApi {
  _FakeSyncApi({this.failFirstPush = false});

  bool failFirstPush;
  bool _failedOnce = false;
  final List<Map<String, List<Map<String, dynamic>>>> pushedBatches =
      <Map<String, List<Map<String, dynamic>>>>[];

  @override
  Future<PullResponse> pull({required int since, int limit = 500}) async {
    return PullResponse(
      serverTime: DateTime.now().millisecondsSinceEpoch,
      hasMore: false,
      changes: const <String, List<Map<String, dynamic>>>{},
    );
  }

  @override
  Future<PushResponse> push(Map<String, List<Map<String, dynamic>>> changes) async {
    if (failFirstPush && !_failedOnce) {
      _failedOnce = true;
      throw const NetworkUnavailableException('网络不可用，已切换为本地模式');
    }
    pushedBatches.add(changes);
    final accepted = <String>[
      for (final rows in changes.values)
        for (final row in rows) (row['id'] ?? '').toString(),
    ];
    return PushResponse(
      serverTime: DateTime.now().millisecondsSinceEpoch,
      accepted: accepted,
      conflicts: const <String>[],
      rejected: const <String>[],
    );
  }

  List<String> get pushedIds => <String>[
        for (final batch in pushedBatches)
          for (final rows in batch.values)
            for (final row in rows) (row['id'] ?? '').toString(),
      ];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const cloudUid = 'u-cloud-777';

  late AppDatabase db;
  late _FakeSyncApi api;
  late SyncService service;
  late SyncDao syncDao;
  late AccountMigrator migrator;
  late bool migrationDone;

  /// 构造迁移器：云端 uid / 迁移标记通过闭包注入（等价 TokenStore 语义）。
  AccountMigrator buildMigrator({required bool failFirstPush}) {
    api = _FakeSyncApi(failFirstPush: failFirstPush);
    service = SyncService(db: db, api: api);
    service.setSessionAvailable(true);
    service.setCloudUid(cloudUid);
    syncDao = SyncDao(db);
    return AccountMigrator(
      db: db,
      syncService: service,
      syncDao: syncDao,
      cloudUidResolver: () async => cloudUid,
      migrationDoneReader: () async => migrationDone,
      markMigrationDone: () async => migrationDone = true,
    );
  }

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    migrationDone = false;
    migrator = buildMigrator(failFirstPush: false);
  });

  tearDown(() async {
    service.dispose();
    await db.close();
  });

  /// v1 本机账号的存量数据（user_id 为本地 uid）。
  Future<void> seedLocalData() async {
    const now = '2026-11-24T03:00:00.000Z';
    await db.into(db.ledgers).insert(
          LedgersCompanion.insert(
            id: 'ledger-1',
            userId: 'local-uid',
            name: '日常账本',
            createdAt: now,
            updatedAt: now,
          ),
        );
    await db.into(db.bills).insert(
          BillsCompanion.insert(
            id: 'bill-1',
            ledgerId: 'ledger-1',
            categoryId: 'cat-1',
            type: 'expense',
            amountCents: 2500,
            billDate: '2026-11-24',
            createdAt: now,
            updatedAt: now,
          ),
        );
    await db.into(db.categories).insert(
          CategoriesCompanion.insert(
            id: 'cat-1',
            userId: 'local-uid',
            name: '餐饮',
            type: 'expense',
            updatedAt: const Value(now),
          ),
        );
    await db.into(db.savingsGoals).insert(
          SavingsGoalsCompanion.insert(
            id: 'goal-1',
            userId: 'local-uid',
            name: '旅行基金',
            targetAmountCents: 300000,
            createdAt: now,
            updatedAt: now,
          ),
        );
    await db.into(db.goalLedgerBindings).insert(
          GoalLedgerBindingsCompanion.insert(
            goalId: 'goal-1',
            ledgerId: 'ledger-1',
            userId: const Value(''), // v4 迁移后为空，等待补归属
            createdAt: now,
            updatedAt: const Value(''),
          ),
        );
  }

  Future<int> countRows(String table) async {
    final rows = await db.customSelect('SELECT COUNT(*) AS c FROM $table').get();
    return rows.first.read<int>('c');
  }

  group('AccountMigrator 本机数据升级上云', () {
    test('待迁移检测：存在非云端归属的行', () async {
      expect(await migrator.needsMigration(), isFalse); // 无数据
      await seedLocalData();
      expect(await migrator.needsMigration(), isTrue);
    });

    test('迁移把 user_id 重写为云端 uid 并全量上传，不删本地数据', () async {
      await seedLocalData();
      final before = <String, int>{
        for (final table in <String>[
          'ledgers',
          'bills',
          'categories',
          'savings_goals',
          'goal_ledger_bindings',
        ])
          table: await countRows(table),
      };

      final result = await migrator.migrate();

      expect(result.success, isTrue);
      expect(result.uploadedRows, before.values.reduce((a, b) => a + b));

      // 1) 归属全部改写为云端 uid（含原本为空的复合主键表）
      expect(await syncDao.countForeignRows(cloudUid), 0);
      final ledgers = await db.select(db.ledgers).get();
      expect(ledgers.single.userId, cloudUid);
      final bindings = await db.select(db.goalLedgerBindings).get();
      expect(bindings.single.userId, cloudUid);
      expect(bindings.single.updatedAt, isNotEmpty); // 空时间戳已回填

      // 2) 全量上传（服务端盖章 user_id，行内不含 user_id 字段）
      expect(api.pushedIds.toSet(), containsAll(<String>['ledger-1', 'bill-1']));
      expect(api.pushedIds, contains('goal-1'));
      final pushedBills = api.pushedBatches
          .expand((batch) => batch['bills'] ?? const <Map<String, dynamic>>[])
          .toList();
      expect(pushedBills.single.containsKey('userId'), isFalse);

      // 3) 本地行数不变（迁移红线：只写不改删）
      for (final entry in before.entries) {
        expect(await countRows(entry.key), entry.value, reason: entry.key);
      }
      expect(migrationDone, isTrue);
      expect(await migrator.needsMigration(), isFalse); // 标记完成后不再提示
    });

    test('迁移中断可重试且不丢数据，重复执行幂等', () async {
      await seedLocalData();
      // 首次 push 失败（模拟断网中断）
      service.dispose();
      migrator = buildMigrator(failFirstPush: true);

      await expectLater(migrator.migrate(), throwsA(isA<NetworkUnavailableException>()));

      // 中断后本地数据完好（仅归属已改写）
      expect(await countRows('ledgers'), 1);
      expect(await countRows('bills'), 1);
      expect(migrationDone, isFalse);

      // 重试成功
      api.failFirstPush = false;
      final retry = await migrator.migrate();
      expect(retry.success, isTrue);
      expect(migrationDone, isTrue);
      expect(await countRows('bills'), 1);
      expect(await syncDao.countForeignRows(cloudUid), 0);

      // 再次执行：幂等（行数不变、无重复行）
      final again = await migrator.migrate();
      expect(again.success, isTrue);
      expect(await countRows('bills'), 1);
      expect(await countRows('goal_ledger_bindings'), 1);
    });
  });
}
