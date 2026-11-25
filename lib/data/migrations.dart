import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../core/config.dart';
import '../core/uuid.dart';
import 'database.dart';

/// Reads a nullable string from a raw query row.
///
/// 注意：Drift 2.35 的 `QueryRow.read` 需要可推断的 Dart 类型，
/// `read<Object?>` 会抛「Could not find a matching SQL type for Object?」，
/// 因此统一走带类型的 [QueryRow.readNullable]。
String? _readNullableString(QueryRow row, String column) =>
    row.readNullable<String>(column);

/// Runs a raw SELECT and returns the resulting rows. Drift 2.35 removed the old
/// `customQuery` helper, so all raw reads go through `customSelect(...).get()`.
Future<List<QueryRow>> _rawSelect(
  AppDatabase db,
  String sql, [
  List<Object?> variables = const [],
]) {
  return db
      .customSelect(
        sql,
        variables: variables.map((value) => Variable<Object>(value)).toList(),
      )
      .get();
}

Future<bool> tableExists(AppDatabase db, String tableName) async {
  final rows = await _rawSelect(
    db,
    "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
    <Object?>[tableName],
  );
  return rows.isNotEmpty;
}

Future<bool> _columnExists(AppDatabase db, String table, String column) async {
  final rows = await _rawSelect(db, 'PRAGMA table_info($table)');
  for (final row in rows) {
    if (_readNullableString(row, 'name') == column) {
      return true;
    }
  }
  return false;
}

/// Creates a one-time physical backup before the destructive v1 -> v2 rewrite.
Future<void> backupDatabaseBeforeV2() async {
  final directory = await getApplicationDocumentsDirectory();
  final source = File(p.join(directory.path, AppConfig.databaseName));
  if (!await source.exists()) {
    return;
  }
  final backup = File(p.join(directory.path, AppConfig.backupDatabaseName));
  if (!await backup.exists()) {
    await source.copy(backup.path);
  }
}

/// v1 -> v2: archive historical manual deposits, migrate them into an opening
/// balance bill where a ledger was linked, rebuild `savings_goals` without the
/// retired snapshot columns, then drop `deposit_records`.
///
/// Runs in one Drift transaction. The caller has already created a physical
/// backup of `savesave.db` before opening the upgraded schema.
Future<void> migrateV1ToV2(AppDatabase db, Migrator migrator) async {
  await db.transaction(() async {
    await migrator.createTable(db.legacyDepositArchive);

    final hasLegacyTable = await tableExists(db, 'deposit_records');
    if (!hasLegacyTable) {
      return;
    }

    final now = DateTime.now().toUtc().toIso8601String();
    final hasLinkedColumn =
        await _columnExists(db, 'savings_goals', 'linked_ledger_id');

    // 1) Full read-only archive of every historical deposit (idempotent by
    //    source_bill_id = original deposit id).
    final deposits = await _rawSelect(
      db,
      'SELECT id, goal_id, amount_cents, note FROM deposit_records',
    );
    for (final deposit in deposits) {
      await db.customStatement(
        'INSERT OR IGNORE INTO legacy_deposit_archive '
        '(id, goal_id, amount_cents, source_bill_id, note, archived_at) '
        'VALUES (?, ?, ?, ?, ?, ?)',
        <Object?>[
          Uuid.v4(),
          _readNullableString(deposit, 'goal_id'),
          deposit.read<int>('amount_cents'),
          _readNullableString(deposit, 'id'),
          _readNullableString(deposit, 'note'),
          now,
        ],
      );
    }

    // 2) Goals with a linked ledger get one opening-balance income bill so the
    //    new ledger-derived progress stays continuous.
    if (hasLinkedColumn) {
      final linkedGoals = await _rawSelect(
        db,
        'SELECT id, linked_ledger_id FROM savings_goals '
        "WHERE linked_ledger_id IS NOT NULL AND linked_ledger_id != ''",
      );
      for (final goal in linkedGoals) {
        final goalId = _readNullableString(goal, 'id');
        final ledgerId = _readNullableString(goal, 'linked_ledger_id');
        if (goalId == null || ledgerId == null) {
          continue;
        }
        final sums = await _rawSelect(
          db,
          'SELECT COALESCE(SUM(amount_cents), 0) AS total '
          'FROM deposit_records WHERE goal_id = ?',
          <Object?>[goalId],
        );
        final total = sums.isEmpty ? 0 : sums.first.read<int>('total');
        if (total <= 0) {
          continue;
        }

        final incomeCategory = await _rawSelect(
          db,
          "SELECT id FROM categories WHERE type = 'income' "
          "AND name = '其他' LIMIT 1",
        );
        String categoryId;
        if (incomeCategory.isEmpty) {
          categoryId = 'migration_income';
          await db.customStatement(
            'INSERT OR IGNORE INTO categories '
            "(id, user_id, name, type, icon, color, is_custom, sort_order) "
            "VALUES (?, '', '其他', 'income', '', '#C6A15B', 0, 0)",
            <Object?>[categoryId],
          );
        } else {
          categoryId = _readNullableString(incomeCategory.first, 'id') ??
              'migration_income';
        }

        await db.customStatement(
          'INSERT OR IGNORE INTO bills '
          '(id, ledger_id, category_id, type, amount_cents, bill_date, note, '
          'source, created_at, updated_at) '
          'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
          <Object?>[
            Uuid.v4(),
            ledgerId,
            categoryId,
            'income',
            total,
            DateTime.now().toString().substring(0, 10),
            '历史存入迁移（v2）',
            'migration',
            now,
            now,
          ],
        );
      }

      // 3) Rebuild the binding relation from the retired single ledger column.
      await db.customStatement(
        'INSERT OR IGNORE INTO goal_ledger_bindings '
        '(goal_id, ledger_id, created_at) '
        'SELECT id, linked_ledger_id, ? FROM savings_goals '
        "WHERE linked_ledger_id IS NOT NULL AND linked_ledger_id != ''",
        <Object?>[now],
      );
    }

    // 4) Rebuild savings_goals without deposited_amount_cents/linked_ledger_id.
    await db.customStatement('''
CREATE TABLE IF NOT EXISTS savings_goals_v2_new (
  id TEXT NOT NULL PRIMARY KEY,
  user_id TEXT NOT NULL,
  name TEXT NOT NULL,
  target_amount_cents INTEGER NOT NULL,
  deadline TEXT,
  icon TEXT NOT NULL DEFAULT '',
  theme_color TEXT NOT NULL DEFAULT '#1F6F5C',
  note TEXT,
  status TEXT NOT NULL DEFAULT 'active',
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
)
''');
    await db.customStatement('''
INSERT OR REPLACE INTO savings_goals_v2_new
(id, user_id, name, target_amount_cents, deadline, icon, theme_color, note,
 status, created_at, updated_at)
SELECT id, user_id, name, target_amount_cents, deadline,
       COALESCE(icon, ''), COALESCE(theme_color, '#1F6F5C'), note,
       COALESCE(status, 'active'), created_at, updated_at
FROM savings_goals
''');
    await db.customStatement('DROP TABLE savings_goals');
    await db.customStatement(
      'ALTER TABLE savings_goals_v2_new RENAME TO savings_goals',
    );
    await db.customStatement('DROP TABLE deposit_records');
  });
}

/// v2 -> v3: pure table addition, no data migration and fully idempotent.
Future<void> migrateV2ToV3(AppDatabase db, Migrator migrator) async {
  await db.transaction(() async {
    if (!await tableExists(db, 'ai_analysis_reports')) {
      await migrator.createTable(db.aiAnalysisReports);
    }
  });
}

/// v3 -> v4: add email auth columns to `users`. Pure column addition, fully
/// idempotent (guards with PRAGMA checks). A partial unique index keeps the
/// nullable column happy: NULL emails (guest users) never conflict.
Future<void> migrateV3ToV4(AppDatabase db, Migrator migrator) async {
  await db.transaction(() async {
    if (!await _columnExists(db, 'users', 'email')) {
      await db.customStatement('ALTER TABLE users ADD COLUMN email TEXT');
    }
    if (!await _columnExists(db, 'users', 'password_hash')) {
      await db.customStatement(
        'ALTER TABLE users ADD COLUMN password_hash TEXT',
      );
    }
    await db.customStatement(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_users_email '
      'ON users (email) WHERE email IS NOT NULL',
    );
  });
}

/// v4 -> v5：云同步改造（架构 §6.1 / §7 T2）。
///
/// 内容：
/// 1. 同步表补齐同步三件套列（is_deleted / updated_at / 复合主键表补 user_id），
///    全部带默认值，幂等（PRAGMA 检查后才 ALTER）；
/// 2. 新建 sync_states 水位表；
/// 3. 存量数据回填：复合主键表的 user_id 从所属目标继承，
///    无时间戳的表统一补 updated_at（ISO-8601 UTC，供 LWW 与脏扫描使用）。
///
/// 红线：只加列、只回填，不删除、不改写任何业务字段（兼容旧数据）。
Future<void> migrateV4ToV5(AppDatabase db, Migrator migrator) async {
  await db.transaction(() async {
    final nowIso = DateTime.now().toUtc().toIso8601String();

    // ---- 1) 幂等加列 ----
    final additions = <String, List<String>>{
      'ledgers': <String>['is_deleted'],
      'bills': <String>['is_deleted'],
      'savings_goals': <String>['is_deleted'],
      'categories': <String>['updated_at', 'is_deleted'],
      'goal_ledger_bindings': <String>['user_id', 'updated_at', 'is_deleted'],
      'goal_milestones': <String>['user_id', 'updated_at', 'is_deleted'],
      'legacy_deposit_archive': <String>['user_id'],
      'ai_analysis_reports': <String>['updated_at', 'is_deleted'],
    };
    const columnDdl = <String, String>{
      'is_deleted': 'INTEGER NOT NULL DEFAULT 0',
      'updated_at': "TEXT NOT NULL DEFAULT ''",
      'user_id': "TEXT NOT NULL DEFAULT ''",
    };
    for (final entry in additions.entries) {
      for (final column in entry.value) {
        if (!await _columnExists(db, entry.key, column)) {
          await db.customStatement(
            'ALTER TABLE ${entry.key} ADD COLUMN $column ${columnDdl[column]}',
          );
        }
      }
    }

    // ---- 2) 水位表 ----
    if (!await tableExists(db, 'sync_states')) {
      await migrator.createTable(db.syncStates);
    }

    // ---- 3) 存量回填 ----
    // 复合主键表 user_id 继承自所属目标（迁移后由 AccountMigrator 统一改写）。
    await db.customStatement(
      'UPDATE goal_ledger_bindings SET user_id = '
      "(SELECT s.user_id FROM savings_goals s WHERE s.id = goal_ledger_bindings.goal_id) "
      "WHERE user_id = '' AND goal_id IN (SELECT id FROM savings_goals)",
    );
    await db.customStatement(
      'UPDATE goal_milestones SET user_id = '
      "(SELECT s.user_id FROM savings_goals s WHERE s.id = goal_milestones.goal_id) "
      "WHERE user_id = '' AND goal_id IN (SELECT id FROM savings_goals)",
    );
    // updated_at 回填：bindings 用 created_at；其余无时间戳表统一用迁移时刻。
    await db.customStatement(
      "UPDATE goal_ledger_bindings SET updated_at = created_at WHERE updated_at = ''",
    );
    await db.customStatement(
      "UPDATE goal_milestones SET updated_at = ? WHERE updated_at = ''",
      <Object?>[nowIso],
    );
    await db.customStatement(
      "UPDATE categories SET updated_at = ? WHERE updated_at = ''",
      <Object?>[nowIso],
    );
    await db.customStatement(
      'UPDATE ai_analysis_reports SET updated_at = created_at WHERE updated_at = ?',
      <Object?>[''],
    );
  });
}
