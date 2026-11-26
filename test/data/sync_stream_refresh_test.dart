import 'package:drift/drift.dart' show TableUpdate;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savesave/core/api_client.dart';
import 'package:savesave/data/database.dart';
import 'package:savesave/data/sync/sync_dao.dart';
import 'package:savesave/data/sync/sync_service.dart';
import 'package:savesave/domain/models/bill.dart' as bill_model;
import 'package:savesave/domain/models/ledger.dart' as ledger_model;

/// P1-1 回归用例：pull 落库后，**已建立**的 Drift 流必须自动刷新。
///
/// 缺陷现场（QA v4 回归报告 §5 P1-1）：全新浏览器登录后首页/账本/账单明细
/// 停在空态、同步徽标却显示「已同步」；稍后新开的页面（新订阅）却能看到
/// 2 个账本 3 条账单。原因是 pull 走 `customStatement` 原生 SQL 通道，
/// 不会触发 Drift 的流更新通知，先建立的 `watchAll()/watchByLedger()` 订阅
/// 永远不会重新查询。
///
/// 本文件锁死修复后的契约：
/// 1. 先订阅 → 再 pull → 流必须自己刷新出数据（不重建订阅）；
/// 2. 重复拉同一批（本地已是最新）不得再发表更新通知，避免自激同步循环；
/// 3. 通知只覆盖业务表，绝不包含 `sync_states`（水位表）。
class _FakeSyncApi implements SyncApi {
  _FakeSyncApi(this.pullHandler);

  final PullResponse Function(int since) pullHandler;

  @override
  Future<PullResponse> pull({required int since, int limit = 500}) async {
    return pullHandler(since);
  }

  @override
  Future<PushResponse> push(
    Map<String, List<Map<String, dynamic>>> changes,
  ) async {
    final accepted = <String>[];
    for (final rows in changes.values) {
      for (final row in rows) {
        final Object? id = row['id'] ??
            '${row['goalId'] ?? ''}:${row['ledgerId'] ?? row['thresholdPct'] ?? ''}';
        accepted.add(id.toString());
      }
    }
    return PushResponse(
      serverTime: DateTime.now().millisecondsSinceEpoch,
      accepted: accepted,
      conflicts: const <String>[],
      rejected: const <String>[],
    );
  }
}

/// 轮询等待条件成立（避免依赖固定 sleep 造成用例不稳定）。
Future<bool> _waitUntil(
  bool Function() condition, {
  Duration timeout = const Duration(seconds: 3),
}) async {
  final DateTime deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    if (condition()) {
      return true;
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  return condition();
}

Map<String, dynamic> _ledgerRow({
  required String id,
  required String name,
  String updatedAt = '2026-11-24T03:00:00.000Z',
  int sortOrder = 0,
}) {
  return <String, dynamic>{
    'id': id,
    'name': name,
    'icon': '📒',
    'color': '#1F6F5C',
    'sortOrder': sortOrder,
    'createdAt': '2026-11-24T03:00:00.000Z',
    'updatedAt': updatedAt,
    'isDeleted': false,
    'syncedAt': 1732417200000,
  };
}

Map<String, dynamic> _billRow({
  required String id,
  required String ledgerId,
  required int amountCents,
  String updatedAt = '2026-11-24T03:00:00.000Z',
}) {
  return <String, dynamic>{
    'id': id,
    'ledgerId': ledgerId,
    'categoryId': 'c1',
    'type': amountCents > 0 ? 'expense' : 'income',
    'amountCents': amountCents,
    'billDate': '2026-11-24',
    'note': '测试',
    'source': 'manual',
    'createdAt': '2026-11-24T03:00:00.000Z',
    'updatedAt': updatedAt,
    'isDeleted': false,
    'syncedAt': 1732417200000,
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late SyncDao syncDao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    syncDao = SyncDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('P1-1 pull 落库后已建立的流自动刷新', () {
    test('先订阅 watchAll() 再拉取 → 账本流刷出 2 条，无需重建订阅', () async {
      final List<List<ledger_model.Ledger>> captured =
          <List<ledger_model.Ledger>>[];
      final subscription = db.ledgerDao.watchAll().listen(captured.add);
      addTearDown(subscription.cancel);

      // pull 之前：流已建立且为空态（正是线上 bug 的时序前提）。
      expect(await _waitUntil(() => captured.isNotEmpty), isTrue);
      expect(captured.last, isEmpty);

      final service = SyncService(
        db: db,
        api: _FakeSyncApi(
          (int since) => PullResponse(
            serverTime: DateTime.now().millisecondsSinceEpoch,
            hasMore: false,
            changes: <String, List<Map<String, dynamic>>>{
              'ledgers': <Map<String, dynamic>>[
                _ledgerRow(id: 'l-mobile', name: '手机端账本'),
                _ledgerRow(id: 'l-web', name: '网页端账本', sortOrder: 1),
              ],
            },
          ),
        ),
      );
      addTearDown(service.dispose);
      service.setSessionAvailable(true);
      service.setCloudUid('u-cloud-1');

      await service.syncNow();

      // 关键断言：同一个流（未重建）自己收到了 2 条数据。
      expect(
        await _waitUntil(() => captured.last.length == 2),
        isTrue,
        reason: 'pull 落库后账本流未刷新，首屏会停在空态（P1-1 未修复）',
      );
      expect(
        captured.last.map((ledger_model.Ledger l) => l.name).toList(),
        <String>['手机端账本', '网页端账本'],
      );
    });

    test('先订阅 watchByLedger(all) 再拉取 → 账单流刷出 3 条', () async {
      final List<List<bill_model.Bill>> captured = <List<bill_model.Bill>>[];
      final subscription = db.billDao.watchByLedger('all').listen(captured.add);
      addTearDown(subscription.cancel);

      expect(await _waitUntil(() => captured.isNotEmpty), isTrue);
      expect(captured.last, isEmpty);

      final service = SyncService(
        db: db,
        api: _FakeSyncApi(
          (int since) => PullResponse(
            serverTime: DateTime.now().millisecondsSinceEpoch,
            hasMore: false,
            changes: <String, List<Map<String, dynamic>>>{
              'bills': <Map<String, dynamic>>[
                _billRow(id: 'b1', ledgerId: 'l-web', amountCents: 2500),
                _billRow(id: 'b2', ledgerId: 'l-web', amountCents: 1200),
                _billRow(id: 'b3', ledgerId: 'l-mobile', amountCents: 800),
              ],
            },
          ),
        ),
      );
      addTearDown(service.dispose);
      service.setSessionAvailable(true);
      service.setCloudUid('u-cloud-1');

      await service.syncNow();

      expect(
        await _waitUntil(() => captured.last.length == 3),
        isTrue,
        reason: 'pull 落库后账单流未刷新，账单明细会停在空态（P1-1 未修复）',
      );
    });

    test('流更新规则：只通知被写表的业务数据，绝不包含 sync_states', () async {
      final List<Set<TableUpdate>> updates = <Set<TableUpdate>>[];
      final subscription = db.tableUpdates().listen(updates.add);
      addTearDown(subscription.cancel);

      final int applied = await db.transaction(() async {
        final int count = await syncDao.applyServerRows(
          'ledgers',
          <Map<String, dynamic>>[_ledgerRow(id: 'l-1', name: '账本一')],
          'u-cloud-1',
        );
        await syncDao.savePullWatermark(1732417200000);
        return count;
      });

      expect(applied, 1);
      expect(await _waitUntil(() => updates.isNotEmpty), isTrue);
      final Set<String> touched = <String>{
        for (final Set<TableUpdate> batch in updates)
          for (final TableUpdate update in batch) update.table,
      };
      expect(touched, contains('ledgers'));
      expect(touched, isNot(contains('sync_states')));
    });

    test('本地已是最新时重复拉取 → applied=0 且不再发表更新（不会自激同步）', () async {
      final List<Map<String, dynamic>> rows = <Map<String, dynamic>>[
        _ledgerRow(id: 'l-1', name: '账本一'),
      ];
      expect(await syncDao.applyServerRows('ledgers', rows, 'u-cloud-1'), 1);

      final List<Set<TableUpdate>> updates = <Set<TableUpdate>>[];
      final subscription = db.tableUpdates().listen(updates.add);
      addTearDown(subscription.cancel);

      // 同一批数据再拉一次：本地 updated_at 不小于服务端，全部跳过。
      expect(await syncDao.applyServerRows('ledgers', rows, 'u-cloud-1'), 0);

      await Future<void>.delayed(const Duration(milliseconds: 120));
      expect(
        updates,
        isEmpty,
        reason: '未落库却发表更新会让表格监听器触发下一轮 push，形成自激循环',
      );
    });
  });
}
