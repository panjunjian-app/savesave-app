import 'package:drift/drift.dart';

/// Local user profile. `openid` is nullable to support guest/local mode.
/// v4 adds `email` + `passwordHash` for local email registration (no server:
/// the hash is stored on-device only, see AuthService).
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

  @override
  Set<Column> get primaryKey => {id};
}

/// Many-to-many relation between a goal and the ledgers feeding its balance.
class GoalLedgerBindings extends Table {
  TextColumn get goalId => text()();
  TextColumn get ledgerId => text()();
  TextColumn get createdAt => text()();

  @override
  Set<Column> get primaryKey => {goalId, ledgerId};
}

/// A milestone is recorded once per goal and threshold, never deleted on regression.
class GoalMilestones extends Table {
  TextColumn get goalId => text()();
  IntColumn get thresholdPct => integer()();
  TextColumn get firstReachedDate => text()();

  @override
  Set<Column> get primaryKey => {goalId, thresholdPct};
}

/// A user-created ledger. Every bill belongs to exactly one ledger.
class Ledgers extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  TextColumn get icon => text().withDefault(const Constant(''))();
  TextColumn get color => text().withDefault(const Constant('#1F6F5C'))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Income/expense entries. `amount_cents` is an INTEGER measured in cents.
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

  @override
  Set<Column> get primaryKey => {id};
}

/// Income/expense categories (built-in or user-defined).
class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  TextColumn get icon => text().withDefault(const Constant(''))();
  TextColumn get color => text().withDefault(const Constant('#C6A15B'))();
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Read-only archive of v1 manual deposits (schema v2 migration artifact).
class LegacyDepositArchive extends Table {
  TextColumn get id => text()();
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
class AiAnalysisReports extends Table {
  TextColumn get id => text()();
  TextColumn get scopePeriodType => text()();
  TextColumn get scopePeriodLabel => text()();
  TextColumn get scopeLedgerKey => text()();
  TextColumn get scopeAnchorDate => text()();
  TextColumn get reportJson => text()();
  TextColumn get dataVersion => text()();
  TextColumn get createdAt => text()();
  TextColumn get expiresAt => text()();
  BoolColumn get isStale => boolean().withDefault(const Constant(false))();
  TextColumn get goalKey => text().nullable()();
  TextColumn get modelId => text()();
  TextColumn get consentVersion => text()();

  @override
  Set<Column> get primaryKey => {id};
}
