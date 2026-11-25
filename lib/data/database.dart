import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../core/config.dart';
import 'dao/analysis_report_dao.dart';
import 'dao/balance_dao.dart';
import 'dao/bill_dao.dart';
import 'dao/category_dao.dart';
import 'dao/goal_dao.dart';
import 'dao/ledger_dao.dart';
import 'dao/user_dao.dart';
import 'migrations.dart';
import 'tables.dart';

part 'database.g.dart';

/// Local-only SQLite database. Amounts are stored as INTEGER cents.
@DriftDatabase(
  tables: [
    Users,
    SavingsGoals,
    GoalLedgerBindings,
    GoalMilestones,
    Ledgers,
    Bills,
    Categories,
    LegacyDepositArchive,
    AiAnalysisReports,
    SyncStates,
  ],
  daos: [
    UserDao,
    GoalDao,
    LedgerDao,
    BillDao,
    CategoryDao,
    BalanceDao,
    AnalysisReportDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase({QueryExecutor? executor}) : super(executor ?? _openConnection());

  /// Constructor for tests using an in-memory executor.
  AppDatabase.forTesting(super.executor);

  /// Performance indexes. Created idempotently in [MigrationStrategy.beforeOpen]
  /// (which runs after table creation/migration, so all target tables exist).
  /// Kept here instead of per-table `indexes` overrides because Drift 2.35
  /// replaced that API with non-repeatable class annotations.
  ///
  /// v5 adds per-table `updated_at` indexes for the sync dirty-scan
  /// (`updated_at > last_push_at` 水位扫描，架构 §1.4).
  static const List<String> _indexStatements = <String>[
    'CREATE INDEX IF NOT EXISTS idx_goals_user_status '
        'ON savings_goals (user_id, status)',
    'CREATE INDEX IF NOT EXISTS idx_goal_bindings_ledger '
        'ON goal_ledger_bindings (ledger_id)',
    'CREATE INDEX IF NOT EXISTS idx_bills_ledger_date '
        'ON bills (ledger_id, bill_date)',
    'CREATE INDEX IF NOT EXISTS idx_bills_date_type '
        'ON bills (bill_date, type)',
    'CREATE INDEX IF NOT EXISTS idx_bills_category '
        'ON bills (category_id)',
    'CREATE INDEX IF NOT EXISTS idx_ai_report_scope '
        'ON ai_analysis_reports '
        '(scope_period_type, scope_period_label, scope_ledger_key, created_at DESC)',
    // ---- v5 同步索引 ----
    'CREATE INDEX IF NOT EXISTS idx_bills_updated ON bills (updated_at)',
    'CREATE INDEX IF NOT EXISTS idx_ledgers_updated ON ledgers (updated_at)',
    'CREATE INDEX IF NOT EXISTS idx_goals_updated ON savings_goals (updated_at)',
    'CREATE INDEX IF NOT EXISTS idx_categories_updated ON categories (updated_at)',
    'CREATE INDEX IF NOT EXISTS idx_bindings_updated ON goal_ledger_bindings (updated_at)',
    'CREATE INDEX IF NOT EXISTS idx_milestones_updated ON goal_milestones (updated_at)',
    'CREATE INDEX IF NOT EXISTS idx_reports_updated ON ai_analysis_reports (updated_at)',
  ];

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (migrator) async {
          await migrator.createAll();
        },
        onUpgrade: (migrator, from, to) async {
          if (from < 2) {
            await migrateV1ToV2(this, migrator);
          }
          if (from < 3) {
            await migrateV2ToV3(this, migrator);
          }
          if (from < 4) {
            await migrateV3ToV4(this, migrator);
          }
          if (from < 5) {
            await migrateV4ToV5(this, migrator);
          }
        },
        beforeOpen: (details) async {
          final before = details.versionBefore;
          if (before != null && before < 2) {
            await backupDatabaseBeforeV2();
          }
          await customStatement('PRAGMA foreign_keys = ON');
          for (final statement in _indexStatements) {
            await customStatement(statement);
          }
        },
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: AppConfig.databaseName,
      // On web, drift needs the sqlite3.wasm module and the drift worker.
      // These two files are placed in the web/ directory. Native platforms
      // ignore the `web` option and keep using the local SQLite file.
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    );
  }
}
