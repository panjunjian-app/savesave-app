import 'package:drift/drift.dart';

/// Local user profile. `openid` is nullable to support guest/local mode.
/// v4 adds `email` + `passwordHash` for local email registration (no server:
/// the hash is stored on-device only, see AuthService).
///
/// v3 云同步说明：users 表**不参与同步**（云端 D1 有独立的 users 表，
/// 见 schema/d1_schema.sql）。本地行仅保存展示用资料，登录云端后其 id
/// 由 AccountMigrator 重写为云端 uid。
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get openid => text().nullable().unique()();
  TextColumn get unionid => text().nullable()();
  TextColumn get email => text().nullable().unique()();
  TextColumn get passwordHash => text().nullable()();
  TextColumn get nickname => text().withDefault(const Constant(''))();
  TextColumn get avatarUrl => text().nullable()();
  TextColumn get loginType => text().withDefault(const Constant('guest'))();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Savings goal. v2 removed `deposited_amount_cents` and `linked_ledger_id`:
/// progress is derived from bound ledgers at query time, never persisted.
///
/// v5 adds `isDeleted`（软删同步三件套之一）。
class SavingsGoals extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  IntColumn get targetAmountCents => integer()();
  TextColumn get deadline => text().nullable()();
  TextColumn get icon => text().withDefault(const Constant(''))();
  TextColumn get themeColor => text().withDefault(const Constant('#1F6F5C'))();
  TextColumn get note => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Many-to-many relation between a goal and the ledgers feeding its balance.
///
/// v5 adds `userId/updatedAt/isDeleted`（同步所需；userId 由迁移补齐）。
class GoalLedgerBindings extends Table {
  TextColumn get goalId => text()();
  TextColumn get ledgerId => text()();
  TextColumn get userId => text().withDefault(const Constant(''))();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text().withDefault(const Constant(''))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {goalId, ledgerId};
}

/// A milestone is recorded once per goal and threshold, never deleted on regression.
///
/// v5 adds `userId/updatedAt/isDeleted`（同步所需）。
class GoalMilestones extends Table {
  TextColumn get goalId => text()();
  IntColumn get thresholdPct => integer()();
  TextColumn get userId => text().withDefault(const Constant(''))();
  TextColumn get firstReachedDate => text()();
  TextColumn get updatedAt => text().withDefault(const Constant(''))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {goalId, thresholdPct};
}

/// A user-created ledger. Every bill belongs to exactly one ledger.
///
/// v5 adds `isDeleted`（软删同步）。
class Ledgers extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  TextColumn get icon => text().withDefault(const Constant(''))();
  TextColumn get color => text().withDefault(const Constant('#1F6F5C'))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Income/expense entries. `amount_cents` is an INTEGER measured in cents.
///
/// v5 adds `isDeleted`（软删同步）。
class Bills extends Table {
  TextColumn get id => text()();
  TextColumn get ledgerId => text()();
  TextColumn get categoryId => text()();
  TextColumn get type => text()();
  IntColumn get amountCents => integer()();
  TextColumn get billDate => text()();
  TextColumn get note => text().nullable()();
  TextColumn get source => text().withDefault(const Constant('manual'))();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Income/expense categories (built-in or user-defined).
///
/// v5 adds `updatedAt/isDeleted`（原本无时间戳，LWW 需要补齐）。
class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  TextColumn get icon => text().withDefault(const Constant(''))();
  TextColumn get color => text().withDefault(const Constant('#C6A15B'))();
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get updatedAt => text().withDefault(const Constant(''))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Read-only archive of v1 manual deposits (schema v2 migration artifact).
///
/// v5 adds `userId`：随账号迁移一次性上传云端（不做增量同步）。
class LegacyDepositArchive extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().withDefault(const Constant(''))();
  TextColumn get goalId => text()();
  IntColumn get amountCents => integer()();
  TextColumn get sourceBillId => text().nullable().unique()();
  TextColumn get note => text().nullable()();
  TextColumn get archivedAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Cached AI analysis reports (schema v3). Stores the final, locally-rendered
/// report JSON: all numbers are already authoritative and placeholders resolved.
///
/// v5 adds `updatedAt/isDeleted`：updatedAt 用于脏数据扫描与 LWW（记录
/// 不可变，仅 isStale 标记可变）。
class AiAnalysisReports extends Table {
  TextColumn get id => text()();
  TextColumn get scopePeriodType => text()();
  TextColumn get scopePeriodLabel => text()();
  TextColumn get scopeLedgerKey => text()();
  TextColumn get scopeAnchorDate => text()();
  TextColumn get reportJson => text()();
  TextColumn get dataVersion => text()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text().withDefault(const Constant(''))();
  TextColumn get expiresAt => text()();
  BoolColumn get isStale => boolean().withDefault(const Constant(false))();
  TextColumn get goalKey => text().nullable()();
  TextColumn get modelId => text()();
  TextColumn get consentVersion => text()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// 同步水位元数据（schema v5 新增，架构 §3.2 sync_meta）。
///
/// 单行存储（id = '__global__'）：lastPullSyncedAt 为服务端 synced_at 拉取
/// 水位；lastPushAt 为本地脏数据扫描水位（ISO 字符串，与各表 updated_at
/// 字典序比较）。每表独立水位收益有限，单行更简单可靠。
class SyncStates extends Table {
  /// 固定 '__global__'（单行水位）。
  TextColumn get id => text()();
  IntColumn get lastPullSyncedAt => integer().withDefault(const Constant(0))();
  TextColumn get lastPushAt => text().withDefault(const Constant(''))();
  TextColumn get lastError => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
