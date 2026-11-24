import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../core/config.dart';
import '../core/uuid.dart';
import 'database.dart';

/// Reads a nullable string from a raw query row.
String? _readNullableString(QueryRow row, String column) {
  final value = row.read<Object?>(column);
  return value?.toString();
}

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
