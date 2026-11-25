/// 行 ↔ JSON 编解码（6+1 张同步表的线格式 DTO，架构 §6.1）。
///
/// 约定（架构 §9）：
/// - 与 D1/服务端字段机械同构（snake_case ↔ camelCase），无 ORM 抽象层；
/// - `updatedAt` 统一 ISO-8601 UTC 字符串（毫秒精度），LWW 用字典序比较；
/// - 金额一律 INTEGER 分；
/// - push 行不携带 user_id —— 服务端一律以 JWT sub 盖章（§9.4）。
library;

import 'package:drift/drift.dart';

import '../database.dart';

/// 同步表注册表：key 与服务端 changes 字段一致。
const List<String> kSyncTableKeys = <String>[
  'ledgers',
  'bills',
  'categories',
  'savingsGoals',
  'goalLedgerBindings',
  'goalMilestones',
  'aiAnalysisReports',
];

/// 截断到毫秒的 UTC ISO-8601 时间（统一比较精度，避免微秒打破字典序）。
String isoNowMs() {
  final now = DateTime.now().toUtc();
  return DateTime.utc(
    now.year,
    now.month,
    now.day,
    now.hour,
    now.minute,
    now.second,
    now.millisecond,
  ).toIso8601String();
}

// ============ 编码：本地行 → 服务端线格式 ============

Map<String, dynamic> encodeLedger(Ledger row) => <String, dynamic>{
      'id': row.id,
      'name': row.name,
      'icon': row.icon,
      'color': row.color,
      'sortOrder': row.sortOrder,
      'createdAt': row.createdAt,
      'updatedAt': row.updatedAt,
      'isDeleted': row.isDeleted,
    };

Map<String, dynamic> encodeBill(Bill row) => <String, dynamic>{
      'id': row.id,
      'ledgerId': row.ledgerId,
      'categoryId': row.categoryId,
      'type': row.type,
      'amountCents': row.amountCents,
      'billDate': row.billDate,
      'note': row.note,
      'source': row.source,
      'createdAt': row.createdAt,
      'updatedAt': row.updatedAt,
      'isDeleted': row.isDeleted,
    };

Map<String, dynamic> encodeCategory(Category row) => <String, dynamic>{
      'id': row.id,
      'name': row.name,
      'type': row.type,
      'icon': row.icon,
      'color': row.color,
      'isCustom': row.isCustom,
      'sortOrder': row.sortOrder,
      'updatedAt': row.updatedAt,
      'isDeleted': row.isDeleted,
    };

Map<String, dynamic> encodeSavingsGoal(SavingsGoal row) => <String, dynamic>{
      'id': row.id,
      'name': row.name,
      'targetAmountCents': row.targetAmountCents,
      'deadline': row.deadline,
      'icon': row.icon,
      'themeColor': row.themeColor,
      'note': row.note,
      'status': row.status,
      'createdAt': row.createdAt,
      'updatedAt': row.updatedAt,
      'isDeleted': row.isDeleted,
    };

Map<String, dynamic> encodeGoalLedgerBinding(GoalLedgerBinding row) =>
    <String, dynamic>{
      'goalId': row.goalId,
      'ledgerId': row.ledgerId,
      'createdAt': row.createdAt,
      'updatedAt': row.updatedAt,
      'isDeleted': row.isDeleted,
    };

Map<String, dynamic> encodeGoalMilestone(GoalMilestone row) =>
    <String, dynamic>{
      'goalId': row.goalId,
      'thresholdPct': row.thresholdPct,
      'firstReachedDate': row.firstReachedDate,
      'updatedAt': row.updatedAt,
      'isDeleted': row.isDeleted,
    };

Map<String, dynamic> encodeAiAnalysisReport(AiAnalysisReport row) =>
    <String, dynamic>{
      'id': row.id,
      'scopePeriodType': row.scopePeriodType,
      'scopePeriodLabel': row.scopePeriodLabel,
      'scopeLedgerKey': row.scopeLedgerKey,
      'scopeAnchorDate': row.scopeAnchorDate,
      'reportJson': row.reportJson,
      'dataVersion': row.dataVersion,
      'createdAt': row.createdAt,
      'updatedAt': row.updatedAt,
      'expiresAt': row.expiresAt,
      'isStale': row.isStale,
      'goalKey': row.goalKey,
      'modelId': row.modelId,
      'consentVersion': row.consentVersion,
      'isDeleted': row.isDeleted,
    };

// ============ 解码：服务端线格式 → 本地写入 ============
//
// LWW 落库在 sync_dao.dart 中完成：按 id 比较本地/服务端 updatedAt，
// 服务端较新则整行覆盖（insertOrReplace），本地较新则保留本地
// （本地行 updatedAt 已较新，自然处于脏状态将被回推）。

LedgersCompanion decodeLedger(Map<String, dynamic> row) => LedgersCompanion.insert(
      id: row['id'] as String,
      userId: '', // user_id 服务端盖章语义；本地镜像行归属由迁移统一改写
      name: row['name'] as String? ?? '',
      icon: Value(row['icon'] as String? ?? ''),
      color: Value(row['color'] as String? ?? '#1F6F5C'),
      sortOrder: Value((row['sortOrder'] as num?)?.toInt() ?? 0),
      createdAt: row['createdAt'] as String? ?? isoNowMs(),
      updatedAt: row['updatedAt'] as String? ?? isoNowMs(),
    );

BillsCompanion decodeBill(Map<String, dynamic> row) => BillsCompanion.insert(
      id: row['id'] as String,
      ledgerId: row['ledgerId'] as String? ?? '',
      categoryId: row['categoryId'] as String? ?? '',
      type: row['type'] as String? ?? 'expense',
      amountCents: (row['amountCents'] as num?)?.toInt() ?? 0,
      billDate: row['billDate'] as String? ?? '',
      note: Value(row['note'] as String?),
      source: Value(row['source'] as String? ?? 'manual'),
      createdAt: row['createdAt'] as String? ?? isoNowMs(),
      updatedAt: row['updatedAt'] as String? ?? isoNowMs(),
    );

CategoriesCompanion decodeCategory(Map<String, dynamic> row) =>
    CategoriesCompanion.insert(
      id: row['id'] as String,
      userId: '',
      name: row['name'] as String? ?? '',
      type: row['type'] as String? ?? 'expense',
      icon: Value(row['icon'] as String? ?? ''),
      color: Value(row['color'] as String? ?? '#C6A15B'),
      isCustom: Value(row['isCustom'] == true),
      sortOrder: Value((row['sortOrder'] as num?)?.toInt() ?? 0),
      updatedAt: Value(row['updatedAt'] as String? ?? isoNowMs()),
    );

SavingsGoalsCompanion decodeSavingsGoal(Map<String, dynamic> row) =>
    SavingsGoalsCompanion.insert(
      id: row['id'] as String,
      userId: '',
      name: row['name'] as String? ?? '',
      targetAmountCents: (row['targetAmountCents'] as num?)?.toInt() ?? 0,
      deadline: Value(row['deadline'] as String?),
      icon: Value(row['icon'] as String? ?? ''),
      themeColor: Value(row['themeColor'] as String? ?? '#1F6F5C'),
      note: Value(row['note'] as String?),
      status: Value(row['status'] as String? ?? 'active'),
      createdAt: row['createdAt'] as String? ?? isoNowMs(),
      updatedAt: row['updatedAt'] as String? ?? isoNowMs(),
    );

/// isDeleted 需要覆盖默认值 false，因此单独以 Companion 字段补写。
GoalLedgerBindingsCompanion decodeGoalLedgerBinding(Map<String, dynamic> row) =>
    GoalLedgerBindingsCompanion.insert(
      goalId: row['goalId'] as String,
      ledgerId: row['ledgerId'] as String? ?? '',
      userId: const Value(''),
      createdAt: row['createdAt'] as String? ?? isoNowMs(),
      updatedAt: Value(row['updatedAt'] as String? ?? isoNowMs()),
    );

GoalMilestonesCompanion decodeGoalMilestone(Map<String, dynamic> row) =>
    GoalMilestonesCompanion.insert(
      goalId: row['goalId'] as String,
      thresholdPct: (row['thresholdPct'] as num?)?.toInt() ?? 0,
      userId: const Value(''),
      firstReachedDate: row['firstReachedDate'] as String? ?? '',
      updatedAt: Value(row['updatedAt'] as String? ?? isoNowMs()),
    );

AiAnalysisReportsCompanion decodeAiAnalysisReport(Map<String, dynamic> row) =>
    AiAnalysisReportsCompanion.insert(
      id: row['id'] as String,
      scopePeriodType: row['scopePeriodType'] as String? ?? '',
      scopePeriodLabel: row['scopePeriodLabel'] as String? ?? '',
      scopeLedgerKey: row['scopeLedgerKey'] as String? ?? '',
      scopeAnchorDate: row['scopeAnchorDate'] as String? ?? '',
      reportJson: row['reportJson'] as String? ?? '{}',
      dataVersion: row['dataVersion'] as String? ?? '',
      createdAt: row['createdAt'] as String? ?? isoNowMs(),
      updatedAt: Value(row['updatedAt'] as String? ?? isoNowMs()),
      expiresAt: row['expiresAt'] as String? ?? '',
      isStale: Value(row['isStale'] == true),
      goalKey: Value(row['goalKey'] as String?),
      modelId: row['modelId'] as String? ?? '',
      consentVersion: row['consentVersion'] as String? ?? '',
    );

/// 服务端行的 isDeleted：兼容布尔与 0/1 数字两种编码（D1 存 INTEGER）。
bool decodeIsDeleted(Map<String, dynamic> row) {
  final value = row['isDeleted'];
  return value == true || value == 1;
}
