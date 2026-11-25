-- ============================================================
-- 「省省钱，存存钱」云端 D1 schema（v3 云同步）
-- 时间约定：
--   created_at / updated_at : 客户端逻辑时间，ISO-8601 UTC 字符串（字典序可比，LWW 依据）
--   synced_at               : 服务端毫秒时间戳（INTEGER，增量拉取唯一水位）
-- 金额一律 INTEGER 分；删除一律软删（is_deleted=1 + updated_at=now）。
-- 可重复执行：全部使用 IF NOT EXISTS。
-- ============================================================

-- ============ 账号与会话 ============
CREATE TABLE IF NOT EXISTS users (
  id            TEXT PRIMARY KEY,          -- uuid（服务端生成）
  email         TEXT NOT NULL UNIQUE,      -- 全局唯一，小写归一
  password_hash TEXT NOT NULL,             -- pbkdf2_sha256$150000$salt_b64$hash_b64
  nickname      TEXT NOT NULL DEFAULT '',
  created_at    TEXT NOT NULL,
  updated_at    TEXT NOT NULL,
  is_deleted    INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS refresh_tokens (
  id         TEXT PRIMARY KEY,
  user_id    TEXT NOT NULL REFERENCES users(id),
  token_hash TEXT NOT NULL,                -- sha256(refresh_token)，原文不落库
  expires_at INTEGER NOT NULL,             -- ms，30 天
  revoked    INTEGER NOT NULL DEFAULT 0,   -- 登出/改密置 1
  created_at INTEGER NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_refresh_tokens_user
  ON refresh_tokens (user_id, revoked);

-- ============ 业务表（与本地 Drift 同构 + user_id + 同步三件套）============

CREATE TABLE IF NOT EXISTS ledgers (
  id TEXT PRIMARY KEY, user_id TEXT NOT NULL,
  name TEXT NOT NULL, icon TEXT NOT NULL DEFAULT '',
  color TEXT NOT NULL DEFAULT '#1F6F5C', sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL, updated_at TEXT NOT NULL,
  synced_at INTEGER NOT NULL, is_deleted INTEGER NOT NULL DEFAULT 0
);
CREATE INDEX IF NOT EXISTS idx_ledgers_sync ON ledgers (user_id, synced_at);

CREATE TABLE IF NOT EXISTS bills (
  id TEXT PRIMARY KEY, user_id TEXT NOT NULL,
  ledger_id TEXT NOT NULL, category_id TEXT NOT NULL,
  type TEXT NOT NULL, amount_cents INTEGER NOT NULL,
  bill_date TEXT NOT NULL, note TEXT,
  source TEXT NOT NULL DEFAULT 'manual',
  created_at TEXT NOT NULL, updated_at TEXT NOT NULL,
  synced_at INTEGER NOT NULL, is_deleted INTEGER NOT NULL DEFAULT 0
);
CREATE INDEX IF NOT EXISTS idx_bills_sync ON bills (user_id, synced_at);

CREATE TABLE IF NOT EXISTS categories (
  id TEXT PRIMARY KEY, user_id TEXT NOT NULL,
  name TEXT NOT NULL, type TEXT NOT NULL,
  icon TEXT NOT NULL DEFAULT '', color TEXT NOT NULL DEFAULT '#C6A15B',
  is_custom INTEGER NOT NULL DEFAULT 0, sort_order INTEGER NOT NULL DEFAULT 0,
  updated_at TEXT NOT NULL,                -- 本地该表原本无时间戳，schema v5 补齐
  synced_at INTEGER NOT NULL, is_deleted INTEGER NOT NULL DEFAULT 0
);
CREATE INDEX IF NOT EXISTS idx_categories_sync ON categories (user_id, synced_at);

CREATE TABLE IF NOT EXISTS savings_goals (
  id TEXT PRIMARY KEY, user_id TEXT NOT NULL,
  name TEXT NOT NULL, target_amount_cents INTEGER NOT NULL,
  deadline TEXT, icon TEXT NOT NULL DEFAULT '',
  theme_color TEXT NOT NULL DEFAULT '#1F6F5C', note TEXT,
  status TEXT NOT NULL DEFAULT 'active',
  created_at TEXT NOT NULL, updated_at TEXT NOT NULL,
  synced_at INTEGER NOT NULL, is_deleted INTEGER NOT NULL DEFAULT 0
);
CREATE INDEX IF NOT EXISTS idx_goals_sync ON savings_goals (user_id, synced_at);

-- 复合主键表同样带 user_id + updated_at（本地 schema v5 补齐）
CREATE TABLE IF NOT EXISTS goal_ledger_bindings (
  goal_id TEXT NOT NULL, ledger_id TEXT NOT NULL, user_id TEXT NOT NULL,
  created_at TEXT NOT NULL, updated_at TEXT NOT NULL,
  synced_at INTEGER NOT NULL, is_deleted INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (goal_id, ledger_id)
);
CREATE INDEX IF NOT EXISTS idx_bindings_sync ON goal_ledger_bindings (user_id, synced_at);

CREATE TABLE IF NOT EXISTS goal_milestones (
  goal_id TEXT NOT NULL, threshold_pct INTEGER NOT NULL, user_id TEXT NOT NULL,
  first_reached_date TEXT NOT NULL, updated_at TEXT NOT NULL,
  synced_at INTEGER NOT NULL, is_deleted INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (goal_id, threshold_pct)
);
CREATE INDEX IF NOT EXISTS idx_milestones_sync ON goal_milestones (user_id, synced_at);

-- P1：只读归档，随账号迁移一次性上传，不做增量同步
CREATE TABLE IF NOT EXISTS legacy_deposit_archive (
  id TEXT PRIMARY KEY, user_id TEXT NOT NULL,
  goal_id TEXT NOT NULL, amount_cents INTEGER NOT NULL,
  source_bill_id TEXT, note TEXT, archived_at TEXT NOT NULL,
  synced_at INTEGER NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_archive_sync ON legacy_deposit_archive (user_id, synced_at);

-- P1：AI 分析报告（纯文案 JSON，不可变记录，不含任何 AI Key）
CREATE TABLE IF NOT EXISTS ai_analysis_reports (
  id TEXT PRIMARY KEY, user_id TEXT NOT NULL,
  scope_period_type TEXT NOT NULL, scope_period_label TEXT NOT NULL,
  scope_ledger_key TEXT NOT NULL, scope_anchor_date TEXT NOT NULL,
  report_json TEXT NOT NULL, data_version TEXT NOT NULL,
  created_at TEXT NOT NULL, updated_at TEXT NOT NULL, expires_at TEXT NOT NULL,
  is_stale INTEGER NOT NULL DEFAULT 0, goal_key TEXT,
  model_id TEXT NOT NULL, consent_version TEXT NOT NULL,
  synced_at INTEGER NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_reports_sync ON ai_analysis_reports (user_id, synced_at);

-- 限流计数（登录/注册，按 ip+邮箱，滑动窗口简化为 15 分钟计数）
CREATE TABLE IF NOT EXISTS rate_limits (
  key TEXT PRIMARY KEY,        -- 'login:{ip}:{email_hash}' 或 'register:{ip}'
  count INTEGER NOT NULL DEFAULT 0,
  window_start INTEGER NOT NULL
);
