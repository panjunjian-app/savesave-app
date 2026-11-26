import 'package:drift/drift.dart';

import '../database.dart';
import 'sync_models.dart';

/// 同步水位快照。
class SyncWatermarks {
  const SyncWatermarks({
    this.lastPullSyncedAt = 0,
    this.lastPushAt = '',
    this.lastError,
  });

  /// 服务端 synced_at 拉取水位（唯一可信水位，架构 §9.3）。
  final int lastPullSyncedAt;

  /// 本地脏数据扫描水位（ISO 字符串，与 updated_at 字典序比较）。
  final String lastPushAt;

  final String? lastError;
}

/// 同步专用数据访问层（架构 §6.1）。
///
/// 职责：水位读写、脏数据扫描（updated_at > last_push）、服务端行 LWW
/// 落库、账号迁移的 user_id 归属重写。所有行级同步操作幂等（按主键）。
///
/// 说明：合并/落库走自定义 SQL 以精确控制「保留本地 user_id」等细节，
/// 避免逐表生成 Companion 的覆盖歧义；脏数据扫描复用生成的 Drift 行类。
class SyncDao {
  SyncDao(this._db);

  final AppDatabase _db;

  static const String _globalKey = '__global__';

  // ============ 水位 ============

  Future<SyncWatermarks> readWatermarks() async {
    final rows = await _db.customSelect(
      'SELECT last_pull_synced_at, last_push_at, last_error '
      'FROM sync_states WHERE id = ?',
      variables: <Variable<Object>>[const Variable<String>(_globalKey)],
    ).get();
    if (rows.isEmpty) {
      return const SyncWatermarks();
    }
    final row = rows.first;
    return SyncWatermarks(
      lastPullSyncedAt: row.read<int>('last_pull_synced_at'),
      lastPushAt: row.read<String>('last_push_at'),
      lastError: row.readNullable<String>('last_error'),
    );
  }

  Future<void> savePullWatermark(int syncedAt) async {
    await _db.customStatement(
      'INSERT INTO sync_states (id, last_pull_synced_at, last_push_at) '
      'VALUES (?, ?, ?) ON CONFLICT(id) DO UPDATE SET last_pull_synced_at = ?',
      <Object?>[_globalKey, syncedAt, '', syncedAt],
    );
  }

  Future<void> savePushWatermark(String pushedUpToIso) async {
    await _db.customStatement(
      'INSERT INTO sync_states (id, last_pull_synced_at, last_push_at) '
      "VALUES (?, 0, ?) ON CONFLICT(id) DO UPDATE SET last_push_at = ?",
      <Object?>[_globalKey, pushedUpToIso, pushedUpToIso],
    );
  }

  Future<void> saveLastError(String? message) async {
    await _db.customStatement(
      'INSERT INTO sync_states (id, last_pull_synced_at, last_push_at, last_error) '
      "VALUES (?, 0, '', ?) ON CONFLICT(id) DO UPDATE SET last_error = ?",
      <Object?>[_globalKey, message, message],
    );
  }

  // ============ 脏数据扫描（push 侧） ============

  /// 各同步表脏行数（updated_at > last_push，含软删行）。用于 UI 待同步计数。
  Future<int> countDirty(String lastPushAt) async {
    final tables = <String, String>{
      'ledgers': 'ledgers',
      'bills': 'bills',
      'categories': 'categories',
      'savings_goals': 'savings_goals',
      'goal_ledger_bindings': 'goal_ledger_bindings',
      'goal_milestones': 'goal_milestones',
      'ai_analysis_reports': 'ai_analysis_reports',
    };
    var total = 0;
    for (final table in tables.values) {
      final rows = await _db.customSelect(
        'SELECT COUNT(*) AS c FROM $table WHERE updated_at > ?',
        variables: <Variable<Object>>[Variable<String>(lastPushAt)],
      ).get();
      total += rows.first.read<int>('c');
    }
    return total;
  }

  /// 扫描全部脏行并编码为线格式（push 请求体 changes）。
  ///
  /// 行数可能超过单批上限，由 SyncService 分批发送；本方法一次性返回全部。
  Future<Map<String, List<Map<String, dynamic>>>> collectDirtyRows(
    String lastPushAt,
  ) async {
    final changes = <String, List<Map<String, dynamic>>>{};

    final ledgerRows = await (_db.select(_db.ledgers)
          ..where((row) => row.updatedAt.isBiggerThanValue(lastPushAt)))
        .get();
    changes['ledgers'] = ledgerRows.map(encodeLedger).toList();

    final billRows = await (_db.select(_db.bills)
          ..where((row) => row.updatedAt.isBiggerThanValue(lastPushAt)))
        .get();
    changes['bills'] = billRows.map(encodeBill).toList();

    final categoryRows = await (_db.select(_db.categories)
          ..where((row) => row.updatedAt.isBiggerThanValue(lastPushAt)))
        .get();
    changes['categories'] = categoryRows.map(encodeCategory).toList();

    final goalRows = await (_db.select(_db.savingsGoals)
          ..where((row) => row.updatedAt.isBiggerThanValue(lastPushAt)))
        .get();
    changes['savingsGoals'] = goalRows.map(encodeSavingsGoal).toList();

    final bindingRows = await (_db.select(_db.goalLedgerBindings)
          ..where((row) => row.updatedAt.isBiggerThanValue(lastPushAt)))
        .get();
    changes['goalLedgerBindings'] =
        bindingRows.map(encodeGoalLedgerBinding).toList();

    final milestoneRows = await (_db.select(_db.goalMilestones)
          ..where((row) => row.updatedAt.isBiggerThanValue(lastPushAt)))
        .get();
    changes['goalMilestones'] = milestoneRows.map(encodeGoalMilestone).toList();

    final reportRows = await (_db.select(_db.aiAnalysisReports)
          ..where((row) => row.updatedAt.isBiggerThanValue(lastPushAt)))
        .get();
    changes['aiAnalysisReports'] = reportRows.map(encodeAiAnalysisReport).toList();

    return changes;
  }

  // ============ 服务端行 LWW 落库（pull 侧） ============

  /// 将一批服务端行按 LWW 合入本地库，返回实际落库的行数。
  ///
  /// 规则（架构 §6.2）：
  /// - 本地无该行 → 整行插入（user_id 取 [cloudUid]）；
  /// - 服务端 updatedAt 较新 → 覆盖本地（保留本地已有 user_id）；
  /// - 本地较新 → 保留本地（本地行本就处于脏状态，将被回推）。
  /// 软删行同样按上述规则落库，删除随 isDeleted 传播。
  ///
  /// 只要本批真正落库了 >=1 行，就主动分发一次该表的 Drift 流更新通知
  /// （见 [_notifyTableUpdated]），保证已建立的 `watch*` 订阅立即重新查询。
  Future<int> applyServerRows(
    String tableKey,
    List<Map<String, dynamic>> rows,
    String cloudUid,
  ) async {
    var applied = 0;
    for (final row in rows) {
      final updatedAt = row['updatedAt'] as String? ?? '';
      if (updatedAt.isEmpty) {
        continue;
      }
      final existing = await _readExistingUpdatedAt(tableKey, row);
      if (existing != null && existing.compareTo(updatedAt) >= 0) {
        continue; // 本地较新或相等：保留本地
      }
      await _upsertServerRow(tableKey, row, cloudUid);
      applied++;
    }
    if (applied > 0) {
      _notifyTableUpdated(tableKey);
    }
    return applied;
  }

  // ============ 流更新通知（原生 SQL 通道的补偿） ============

  /// 表键 → Drift 表元数据；未知表返回 null（不通知）。
  TableInfo? _tableInfoFor(String tableKey) {
    switch (tableKey) {
      case 'ledgers':
        return _db.ledgers;
      case 'bills':
        return _db.bills;
      case 'categories':
        return _db.categories;
      case 'savingsGoals':
        return _db.savingsGoals;
      case 'goalLedgerBindings':
        return _db.goalLedgerBindings;
      case 'goalMilestones':
        return _db.goalMilestones;
      case 'aiAnalysisReports':
        return _db.aiAnalysisReports;
      default:
        return null;
    }
  }

  /// 主动告知 Drift「这张表的数据被改写了」，让所有监听它的流重新查询。
  ///
  /// 为什么必须手动通知：pull 落库走的是 [DatabaseConnectionUser.customStatement]
  /// 原生 SQL 通道，Drift 官方明确该通道**不会**触发流更新（见
  /// `customStatement` 文档：「This method does not update stream queries ...
  /// You can also call markTablesUpdated manually」）。缺少这步补偿时：
  /// 首屏 `ledgersProvider / billsProvider / goalsProvider` 在 pull 之前就已订阅，
  /// 库里已有数据但流不刷新 → 页面长期停在空态，而同步徽标显示「已同步」。
  ///
  /// 安全性：
  /// - 仅在事务内由 Drift 缓冲、提交后统一派发（`transactions.dart` 的
  ///   `TransactionStreamQueryStore`），不会读到未提交数据；
  /// - 只通知 7 张业务表，`sync_states`（水位）不在其中，因此「写水位 →
  ///   触发同步 → 再写水位」的循环不会发生；且调用点带 `applied > 0` 守卫，
  ///   增量拉取拿到 0 行时不会引发任何额外同步。
  void _notifyTableUpdated(String tableKey) {
    final TableInfo? table = _tableInfoFor(tableKey);
    if (table == null) {
      return;
    }
    _db.markTablesUpdated(<TableInfo>[table]);
  }

  /// 读取本地现有行的 updated_at（复合主键按表区分）。无行返回 null。
  Future<String?> _readExistingUpdatedAt(
    String tableKey,
    Map<String, dynamic> row,
  ) async {
    switch (tableKey) {
      case 'ledgers':
        return _scalar('SELECT updated_at FROM ledgers WHERE id = ?', [row['id']]);
      case 'bills':
        return _scalar('SELECT updated_at FROM bills WHERE id = ?', [row['id']]);
      case 'categories':
        return _scalar('SELECT updated_at FROM categories WHERE id = ?', [row['id']]);
      case 'savingsGoals':
        return _scalar('SELECT updated_at FROM savings_goals WHERE id = ?', [row['id']]);
      case 'goalLedgerBindings':
        return _scalar(
          'SELECT updated_at FROM goal_ledger_bindings WHERE goal_id = ? AND ledger_id = ?',
          [row['goalId'], row['ledgerId']],
        );
      case 'goalMilestones':
        return _scalar(
          'SELECT updated_at FROM goal_milestones WHERE goal_id = ? AND threshold_pct = ?',
          [row['goalId'], row['thresholdPct']],
        );
      case 'aiAnalysisReports':
        return _scalar('SELECT updated_at FROM ai_analysis_reports WHERE id = ?', [row['id']]);
      default:
        return null;
    }
  }

  Future<String?> _scalar(String sql, List<Object?> variables) async {
    final rows = await _db.customSelect(
      sql,
      variables: variables.map((value) => Variable<Object>(value)).toList(),
    ).get();
    if (rows.isEmpty) {
      return null;
    }
    return rows.first.readNullable<String>('updated_at');
  }

  /// 整行 upsert（INSERT OR REPLACE）。已存在行保留原 user_id：
  /// 先读旧值再覆盖写回，避免镜像行的归属被服务端行清空。
  Future<void> _upsertServerRow(
    String tableKey,
    Map<String, dynamic> row,
    String cloudUid,
  ) async {
    final isDeleted = row['isDeleted'] == true ? 1 : 0;
    final updatedAt = row['updatedAt'] as String? ?? isoNowMs();

    switch (tableKey) {
      case 'ledgers':
        await _db.customStatement(
          'INSERT OR REPLACE INTO ledgers '
          '(id, user_id, name, icon, color, sort_order, created_at, updated_at, is_deleted) '
          'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
          <Object?>[
            row['id'],
            await _preserveUserId('ledgers', 'id = ?', [row['id']], cloudUid),
            row['name'] ?? '',
            row['icon'] ?? '',
            row['color'] ?? '#1F6F5C',
            row['sortOrder'] ?? 0,
            row['createdAt'] ?? updatedAt,
            updatedAt,
            isDeleted,
          ],
        );
      case 'bills':
        await _db.customStatement(
          'INSERT OR REPLACE INTO bills '
          '(id, ledger_id, category_id, type, amount_cents, bill_date, note, '
          'source, created_at, updated_at, is_deleted) '
          'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
          <Object?>[
            row['id'],
            row['ledgerId'] ?? '',
            row['categoryId'] ?? '',
            row['type'] ?? 'expense',
            row['amountCents'] ?? 0,
            row['billDate'] ?? '',
            row['note'],
            row['source'] ?? 'manual',
            row['createdAt'] ?? updatedAt,
            updatedAt,
            isDeleted,
          ],
        );
      case 'categories':
        await _db.customStatement(
          'INSERT OR REPLACE INTO categories '
          '(id, user_id, name, type, icon, color, is_custom, sort_order, '
          'updated_at, is_deleted) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
          <Object?>[
            row['id'],
            await _preserveUserId('categories', 'id = ?', [row['id']], cloudUid),
            row['name'] ?? '',
            row['type'] ?? 'expense',
            row['icon'] ?? '',
            row['color'] ?? '#C6A15B',
            (row['isCustom'] == true) ? 1 : 0,
            row['sortOrder'] ?? 0,
            updatedAt,
            isDeleted,
          ],
        );
      case 'savingsGoals':
        await _db.customStatement(
          'INSERT OR REPLACE INTO savings_goals '
          '(id, user_id, name, target_amount_cents, deadline, icon, theme_color, '
          'note, status, created_at, updated_at, is_deleted) '
          'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
          <Object?>[
            row['id'],
            await _preserveUserId('savings_goals', 'id = ?', [row['id']], cloudUid),
            row['name'] ?? '',
            row['targetAmountCents'] ?? 0,
            row['deadline'],
            row['icon'] ?? '',
            row['themeColor'] ?? '#1F6F5C',
            row['note'],
            row['status'] ?? 'active',
            row['createdAt'] ?? updatedAt,
            updatedAt,
            isDeleted,
          ],
        );
      case 'goalLedgerBindings':
        await _db.customStatement(
          'INSERT OR REPLACE INTO goal_ledger_bindings '
          '(goal_id, ledger_id, user_id, created_at, updated_at, is_deleted) '
          'VALUES (?, ?, ?, ?, ?, ?)',
          <Object?>[
            row['goalId'],
            row['ledgerId'] ?? '',
            await _preserveUserId(
              'goal_ledger_bindings',
              'goal_id = ? AND ledger_id = ?',
              [row['goalId'], row['ledgerId']],
              cloudUid,
            ),
            row['createdAt'] ?? updatedAt,
            updatedAt,
            isDeleted,
          ],
        );
      case 'goalMilestones':
        await _db.customStatement(
          'INSERT OR REPLACE INTO goal_milestones '
          '(goal_id, threshold_pct, user_id, first_reached_date, updated_at, is_deleted) '
          'VALUES (?, ?, ?, ?, ?, ?)',
          <Object?>[
            row['goalId'],
            row['thresholdPct'] ?? 0,
            await _preserveUserId(
              'goal_milestones',
              'goal_id = ? AND threshold_pct = ?',
              [row['goalId'], row['thresholdPct']],
              cloudUid,
            ),
            row['firstReachedDate'] ?? '',
            updatedAt,
            isDeleted,
          ],
        );
      case 'aiAnalysisReports':
        await _db.customStatement(
          'INSERT OR REPLACE INTO ai_analysis_reports '
          '(id, scope_period_type, scope_period_label, scope_ledger_key, '
          'scope_anchor_date, report_json, data_version, created_at, updated_at, '
          'expires_at, is_stale, goal_key, model_id, consent_version, is_deleted) '
          'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
          <Object?>[
            row['id'],
            row['scopePeriodType'] ?? '',
            row['scopePeriodLabel'] ?? '',
            row['scopeLedgerKey'] ?? '',
            row['scopeAnchorDate'] ?? '',
            row['reportJson'] ?? '{}',
            row['dataVersion'] ?? '',
            row['createdAt'] ?? updatedAt,
            updatedAt,
            row['expiresAt'] ?? '',
            (row['isStale'] == true) ? 1 : 0,
            row['goalKey'],
            row['modelId'] ?? '',
            row['consentVersion'] ?? '',
            isDeleted,
          ],
        );
      default:
        break;
    }
  }

  /// 已存在行保留其 user_id；新行写 [fallback]。
  Future<String> _preserveUserId(
    String table,
    String condition,
    List<Object?> variables,
    String fallback,
  ) async {
    final rows = await _db.customSelect(
      'SELECT user_id FROM $table WHERE $condition LIMIT 1',
      variables: variables.map((value) => Variable<Object>(value)).toList(),
    ).get();
    if (rows.isEmpty) {
      return fallback;
    }
    final existing = rows.first.readNullable<String>('user_id');
    return (existing == null || existing.isEmpty) ? fallback : existing;
  }

  // ============ 账号迁移（AccountMigrator 使用，架构 §6.4） ============

  /// 一次性把本地数据的 user_id 归属重写为云端 uid（单事务，只写不删）。
  ///
  /// 覆盖 5 张带 user_id 的表（bills/ai_analysis_reports 本地无该列，
  /// 服务端按 JWT 盖章，无需重写）；同时回填缺失的 updated_at。
  ///
  /// 事务提交后主动通知这 5 张表的流重新查询：迁移会改写 `updated_at`，
  /// 若不同步刷新，设置页/首页可能展示迁移前的旧快照。
  Future<void> rewriteOwnership(String cloudUid) async {
    final now = isoNowMs();
    await _db.transaction(() async {
      await _db.customStatement(
        'UPDATE ledgers SET user_id = ? WHERE user_id != ?',
        <Object?>[cloudUid, cloudUid],
      );
      await _db.customStatement(
        'UPDATE savings_goals SET user_id = ? WHERE user_id != ?',
        <Object?>[cloudUid, cloudUid],
      );
      await _db.customStatement(
        'UPDATE categories SET user_id = ? WHERE user_id != ?',
        <Object?>[cloudUid, cloudUid],
      );
      await _db.customStatement(
        'UPDATE goal_ledger_bindings SET user_id = ?, '
        "updated_at = CASE WHEN updated_at = '' THEN ? ELSE updated_at END "
        'WHERE user_id != ?',
        <Object?>[cloudUid, now, cloudUid],
      );
      await _db.customStatement(
        'UPDATE goal_milestones SET user_id = ?, '
        "updated_at = CASE WHEN updated_at = '' THEN ? ELSE updated_at END "
        'WHERE user_id != ?',
        <Object?>[cloudUid, now, cloudUid],
      );
      await _db.customStatement(
        'UPDATE legacy_deposit_archive SET user_id = ? WHERE user_id != ?',
        <Object?>[cloudUid, cloudUid],
      );
    });
    // 事务已提交：这 5 张业务表的归属/时间戳发生了变化，通知流重新查询。
    _db.markTablesUpdated(<TableInfo>[
      _db.ledgers,
      _db.savingsGoals,
      _db.categories,
      _db.goalLedgerBindings,
      _db.goalMilestones,
    ]);
  }

  /// 校验归属重写是否完整：返回仍不属于 cloudUid 的行数（应为 0）。
  Future<int> countForeignRows(String cloudUid) async {
    const tables = <String>[
      'ledgers',
      'savings_goals',
      'categories',
      'goal_ledger_bindings',
      'goal_milestones',
      'legacy_deposit_archive',
    ];
    var total = 0;
    for (final table in tables) {
      final rows = await _db.customSelect(
        'SELECT COUNT(*) AS c FROM $table WHERE user_id != ?',
        variables: <Variable<Object>>[Variable<String>(cloudUid)],
      ).get();
      total += rows.first.read<int>('c');
    }
    return total;
  }
}
