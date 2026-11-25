import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savesave/core/api_client.dart';
import 'package:savesave/data/database.dart';
import 'package:savesave/data/sync/sync_service.dart';

/// 可控同步通道 mock：记录每次 push 的行，pull 返回预置响应。
class _FakeSyncApi implements SyncApi {
  _FakeSyncApi();

  /// pull 响应工厂（默认空变更）。
  PullResponse Function(int since)? onPull;

  /// 全部 push 批次（按调用顺序）。
  final List<Map<String, List<Map<String, dynamic>>>> pushedBatches =
      <Map<String, List<Map<String, dynamic>>>>[];

  int pullCalls = 0;

  @override
  Future<PullResponse> pull({required int since, int limit = 500}) async {
    pullCalls++;
    final handler = onPull;
    if (handler != null) {
      return handler(since);
    }
    return PullResponse(
      serverTime: DateTime.now().millisecondsSinceEpoch,
      hasMore: false,
      changes: const <String, List<Map<String, dynamic>>>{},
    );
  }

  @override
  Future<PushResponse> push(Map<String, List<Map<String, dynamic>>> changes) async {
    pushedBatches.add(changes);
    final accepted = <String>[];
    for (final rows in changes.values) {
      for (final row in rows) {
        final id = row['id'] ??
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

  /// 所有推送过的行 id（拍平，便于断言「只推脏数据」）。
  List<String> get pushedIds => <String>[
        for (final batch in pushedBatches)
          for (final rows in batch.values)
            for (final row in rows)
              (row['id'] ??
                      '${row['goalId'] ?? ''}:${row['ledgerId'] ?? row['thresholdPct'] ?? ''}')
                  .toString(),
      ];
}

/// 构造一条账单行（金额一律 INTEGER 分）。
Future<void> _insertBill(
  AppDatabase db, {
  required String id,
  required String updatedAt,
  int amountCents = 2500,
  String ledgerId = 'l1',
  bool isDeleted = false,
}) {
  return db.into(db.bills).insert(
        BillsCompanion.insert(
          id: id,
          ledgerId: ledgerId,
          categoryId: 'c1',
          type: 'expense',
          amountCents: amountCents,
          billDate: '2026-11-24',
          note: const Value('测试'),
          createdAt: updatedAt,
          updatedAt: updatedAt,
          isDeleted: Value(isDeleted),
        ),
      );
}

/// 构造一条账本行。
Future<void> _insertLedger(
  AppDatabase db, {
  required String id,
  required String updatedAt,
  String userId = 'u-cloud-1',
}) {
  return db.into(db.ledgers).insert(
        LedgersCompanion.insert(
          id: id,
          userId: userId,
          name: '日常账本',
          createdAt: updatedAt,
          updatedAt: updatedAt,
        ),
      );
}

/// 未来 1 秒的 ISO 时间：确保严格大于上一轮推送水位（毫秒精度）。
String _futureIso() =>
    DateTime.now().toUtc().add(const Duration(seconds: 1)).toIso8601String();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late _FakeSyncApi api;
  late SyncService service;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    api = _FakeSyncApi();
    service = SyncService(db: db, api: api);
    service.setSessionAvailable(true);
    service.setCloudUid('u-cloud-1');
  });

  tearDown(() async {
    service.dispose();
    await db.close();
  });

  group('SyncService 推送（push）', () {
    test('首次同步推送全部存量数据，之后只推 updated_at > 水位的脏数据', () async {
      final t0 = DateTime.now().toUtc().toIso8601String();
      await _insertBill(db, id: 'bill-a', updatedAt: t0);
      await _insertLedger(db, id: 'ledger-a', updatedAt: t0);

      await service.syncNow();
      expect(api.pushedIds.toSet(), <String>{'bill-a', 'ledger-a'});

      // 干净行不应重复推送
      api.pushedBatches.clear();
      await service.syncNow();
      expect(api.pushedIds, isEmpty);

      // 新增脏行 → 只推这一条
      await _insertBill(db, id: 'bill-b', updatedAt: _futureIso(), amountCents: 800);
      await service.syncNow();
      expect(api.pushedIds, <String>['bill-b']);
    });

    test('软删行同样进入推送（删除可传播）', () async {
      final t0 = DateTime.now().toUtc().toIso8601String();
      await _insertBill(db, id: 'bill-del', updatedAt: t0);
      await service.syncNow();
      api.pushedBatches.clear();

      // DAO 软删：is_deleted=1 + updated_at=now（架构 §9.7）
      await db.billDao.remove('bill-del');
      await service.syncNow();

      expect(api.pushedIds, contains('bill-del'));
      final deletedRow = api.pushedBatches
          .expand((batch) => batch['bills'] ?? const <Map<String, dynamic>>[])
          .firstWhere((row) => row['id'] == 'bill-del');
      expect(deletedRow['isDeleted'], isTrue);
    });
  });

  group('SyncService 拉取（pull）', () {
    test('拉取增量并合并落库', () async {
      api.onPull = (int since) => PullResponse(
            serverTime: DateTime.now().millisecondsSinceEpoch,
            hasMore: false,
            changes: <String, List<Map<String, dynamic>>>{
              'bills': <Map<String, dynamic>>[
                <String, dynamic>{
                  'id': 'bill-server',
                  'ledgerId': 'l1',
                  'categoryId': 'c1',
                  'type': 'expense',
                  'amountCents': 2500,
                  'billDate': '2026-11-24',
                  'note': null,
                  'source': 'manual',
                  'createdAt': '2026-11-24T03:00:00.000Z',
                  'updatedAt': '2026-11-24T03:00:00.000Z',
                  'isDeleted': false,
                  'syncedAt': DateTime.now().millisecondsSinceEpoch,
                },
              ],
            },
          );

      await service.syncNow();

      final rows = await db.select(db.bills).get();
      expect(rows, hasLength(1));
      expect(rows.first.id, 'bill-server');
      expect(rows.first.amountCents, 2500);
    });

    test('LWW：服务端 updatedAt 较新 → 覆盖本地', () async {
      await _insertBill(
        db,
        id: 'bill-lww',
        updatedAt: '2026-11-24T03:00:00.000Z',
        amountCents: 300,
      );
      api.onPull = (int since) => PullResponse(
            serverTime: DateTime.now().millisecondsSinceEpoch,
            hasMore: false,
            changes: <String, List<Map<String, dynamic>>>{
              'bills': <Map<String, dynamic>>[
                <String, dynamic>{
                  'id': 'bill-lww',
                  'ledgerId': 'l1',
                  'categoryId': 'c1',
                  'type': 'expense',
                  'amountCents': 500,
                  'billDate': '2026-11-24',
                  'note': null,
                  'source': 'manual',
                  'createdAt': '2026-11-24T03:00:00.000Z',
                  'updatedAt': '2026-11-24T05:00:00.000Z',
                  'isDeleted': false,
                  'syncedAt': DateTime.now().millisecondsSinceEpoch,
                },
              ],
            },
          );

      await service.syncNow();

      final row = await (db.select(db.bills)
            ..where((table) => table.id.equals('bill-lww')))
          .getSingle();
      expect(row.amountCents, 500); // 服务端较新，覆盖
    });

    test('LWW：本地 updatedAt 较新 → 保留本地并回推', () async {
      await _insertBill(
        db,
        id: 'bill-local-new',
        updatedAt: '2026-11-24T05:00:00.000Z',
        amountCents: 900,
      );
      api.onPull = (int since) => PullResponse(
            serverTime: DateTime.now().millisecondsSinceEpoch,
            hasMore: false,
            changes: <String, List<Map<String, dynamic>>>{
              'bills': <Map<String, dynamic>>[
                <String, dynamic>{
                  'id': 'bill-local-new',
                  'ledgerId': 'l1',
                  'categoryId': 'c1',
                  'type': 'expense',
                  'amountCents': 100,
                  'billDate': '2026-11-24',
                  'note': null,
                  'source': 'manual',
                  'createdAt': '2026-11-24T03:00:00.000Z',
                  'updatedAt': '2026-11-24T03:00:00.000Z',
                  'isDeleted': false,
                  'syncedAt': DateTime.now().millisecondsSinceEpoch,
                },
              ],
            },
          );

      await service.syncNow();

      final row = await (db.select(db.bills)
            ..where((table) => table.id.equals('bill-local-new')))
          .getSingle();
      expect(row.amountCents, 900); // 本地较新，不被旧数据覆盖
      expect(api.pushedIds, contains('bill-local-new')); // 且被回推
    });
  });

  group('SyncService 离线队列', () {
    test('离线写入不丢，恢复会话后自动补推', () async {
      service.setSessionAvailable(false);

      await _insertBill(
        db,
        id: 'bill-offline',
        updatedAt: DateTime.now().toUtc().toIso8601String(),
        amountCents: 1234,
      );
      await service.syncNow();

      expect(api.pushedBatches, isEmpty); // 离线不推送
      expect(await service.pendingCount(), 1); // 待同步队列有 1 条
      expect(service.status.phase, SyncPhase.offline);

      // 恢复联网/会话 → 自动补推
      service.setSessionAvailable(true);
      await service.syncNow();

      expect(api.pushedIds, contains('bill-offline'));
      expect(await service.pendingCount(), 0);
      expect(service.status.phase, SyncPhase.idle);
    });
  });
}
