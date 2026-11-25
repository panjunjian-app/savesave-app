/**
 * POST /api/sync/push —— 批量 upsert + LWW（架构 §4.7）。
 *
 * 服务端逐行幂等逻辑：
 * 1) user_id 一律以 JWT sub 盖章，忽略客户端上报（S5 杜绝水平越权）；
 * 2) 无现有行 → INSERT（synced_at = server_now）；
 * 3) incoming.updatedAt > existing.updatedAt（ISO 字符串字典序）→ UPDATE；
 * 4) incoming.updatedAt 超前服务端 >5 分钟 → 钳制为服务端时间（R4 防时钟漂移）；
 * 5) 否则跳过，行 id 记入 conflicts，客户端据此回滚本地行为云端版本；
 * 6) 写入统一 db.batch 事务提交；失败整体回滚。
 */

import { jsonError, jsonOk, readJsonBody } from '../_lib/json';
import type { D1Database, D1PreparedStatement, Env, FunctionContext } from '../_lib/types';

/** 单请求负载上限：2MB（超限客户端自动分批）。 */
const MAX_PAYLOAD_BYTES = 2 * 1024 * 1024;
/** 允许的客户端时钟超前量：5 分钟。 */
const CLOCK_SKEW_MS = 5 * 60 * 1000;

type FieldType = 'string' | 'stringNull' | 'number' | 'boolean' | 'isoTime';

interface FieldSpec {
  json: string;
  column: string;
  type: FieldType;
  /** boolean 在 D1 中存 0/1；number 校验整数。 */
}

interface TableSpec {
  key: string;
  table: string;
  /** 主键字段（复合主键按顺序），单主键表固定 ['id']。 */
  pk: FieldSpec[];
  data: FieldSpec[];
  /**
   * 该表有 `created_at TEXT NOT NULL` 列，且客户端行会带 `createdAt`。
   * INSERT 时必须显式写入（D1 无默认值，缺列会触发 NOT NULL 约束）。
   * 注意：ai_analysis_reports 的 createdAt 已包含在 data 中，此处为 false。
   */
  hasCreatedAt?: boolean;
}

const f = (json: string, column: string, type: FieldType): FieldSpec => ({ json, column, type });

/** 7 张同步表的行格式定义（与客户端 sync_models.dart 机械同构）。 */
const TABLE_SPECS: TableSpec[] = [
  {
    key: 'ledgers',
    table: 'ledgers',
    hasCreatedAt: true,
    pk: [f('id', 'id', 'string')],
    data: [
      f('name', 'name', 'string'),
      f('icon', 'icon', 'string'),
      f('color', 'color', 'string'),
      f('sortOrder', 'sort_order', 'number'),
    ],
  },
  {
    key: 'bills',
    table: 'bills',
    hasCreatedAt: true,
    pk: [f('id', 'id', 'string')],
    data: [
      f('ledgerId', 'ledger_id', 'string'),
      f('categoryId', 'category_id', 'string'),
      f('type', 'type', 'string'),
      f('amountCents', 'amount_cents', 'number'),
      f('billDate', 'bill_date', 'string'),
      f('note', 'note', 'stringNull'),
      f('source', 'source', 'string'),
    ],
  },
  {
    key: 'categories',
    table: 'categories',
    pk: [f('id', 'id', 'string')],
    data: [
      f('name', 'name', 'string'),
      f('type', 'type', 'string'),
      f('icon', 'icon', 'string'),
      f('color', 'color', 'string'),
      f('isCustom', 'is_custom', 'boolean'),
      f('sortOrder', 'sort_order', 'number'),
    ],
  },
  {
    key: 'savingsGoals',
    table: 'savings_goals',
    hasCreatedAt: true,
    pk: [f('id', 'id', 'string')],
    data: [
      f('name', 'name', 'string'),
      f('targetAmountCents', 'target_amount_cents', 'number'),
      f('deadline', 'deadline', 'stringNull'),
      f('icon', 'icon', 'string'),
      f('themeColor', 'theme_color', 'string'),
      f('note', 'note', 'stringNull'),
      f('status', 'status', 'string'),
    ],
  },
  {
    key: 'goalLedgerBindings',
    table: 'goal_ledger_bindings',
    hasCreatedAt: true,
    pk: [f('goalId', 'goal_id', 'string'), f('ledgerId', 'ledger_id', 'string')],
    data: [],
  },
  {
    key: 'goalMilestones',
    table: 'goal_milestones',
    pk: [f('goalId', 'goal_id', 'string'), f('thresholdPct', 'threshold_pct', 'number')],
    data: [f('firstReachedDate', 'first_reached_date', 'string')],
  },
  {
    key: 'aiAnalysisReports',
    table: 'ai_analysis_reports',
    pk: [f('id', 'id', 'string')],
    data: [
      f('scopePeriodType', 'scope_period_type', 'string'),
      f('scopePeriodLabel', 'scope_period_label', 'string'),
      f('scopeLedgerKey', 'scope_ledger_key', 'string'),
      f('scopeAnchorDate', 'scope_anchor_date', 'string'),
      f('reportJson', 'report_json', 'string'),
      f('dataVersion', 'data_version', 'string'),
      f('createdAt', 'created_at', 'isoTime'),
      f('expiresAt', 'expires_at', 'isoTime'),
      f('isStale', 'is_stale', 'boolean'),
      f('goalKey', 'goal_key', 'stringNull'),
      f('modelId', 'model_id', 'string'),
      f('consentVersion', 'consent_version', 'string'),
    ],
  },
];

/**
 * 行字段提取与校验：返回 { error } 表示该行格式非法（记入 rejected）。
 *
 * `requireNonEmpty`：主键字段必须非空；普通数据字段允许空字符串
 * （客户端 Drift 模型对 icon/color/note 等默认就是 ''，若按非空拒绝
 * 会导致这些行永远同步不上去，属于数据丢失级 bug）。
 */
function extractFields(
  row: Record<string, unknown>,
  spec: FieldSpec[],
  requireNonEmpty = false,
): { values: unknown[]; error?: undefined } | { values?: undefined; error: string } {
  const values: unknown[] = [];
  for (const field of spec) {
    const raw = row[field.json];
    switch (field.type) {
      case 'string': {
        if (typeof raw !== 'string' || (requireNonEmpty && raw.length === 0)) {
          return { error: `VALIDATION_ERROR:${field.json}` };
        }
        if (raw.length > 64 * 1024) {
          return { error: `VALIDATION_ERROR:${field.json}` };
        }
        values.push(raw);
        break;
      }
      case 'stringNull': {
        if (raw !== null && raw !== undefined && typeof raw !== 'string') {
          return { error: `VALIDATION_ERROR:${field.json}` };
        }
        values.push(raw === undefined ? null : raw);
        break;
      }
      case 'number': {
        if (typeof raw !== 'number' || !Number.isFinite(raw)) {
          return { error: `VALIDATION_ERROR:${field.json}` };
        }
        values.push(Math.trunc(raw));
        break;
      }
      case 'boolean': {
        if (typeof raw !== 'boolean') {
          return { error: `VALIDATION_ERROR:${field.json}` };
        }
        values.push(raw ? 1 : 0);
        break;
      }
      case 'isoTime': {
        if (typeof raw !== 'string' || Number.isNaN(Date.parse(raw))) {
          return { error: `VALIDATION_ERROR:${field.json}` };
        }
        values.push(raw);
        break;
      }
    }
  }
  return { values };
}

/** LWW 时间钳制（R4）：客户端时间超前服务端 >5 分钟时改为服务端时间。 */
function clampUpdatedAt(incoming: string, serverNowIso: string): string {
  if (Date.parse(incoming) - Date.parse(serverNowIso) > CLOCK_SKEW_MS) {
    return serverNowIso;
  }
  return incoming;
}

/** 复合主键展示 id（accepted/conflicts 中使用）。 */
function compositeRowId(row: Record<string, unknown>, spec: TableSpec): string {
  return spec.pk.map((field) => String(row[field.json] ?? '')).join(':');
}

export const onRequestPost = async (context: FunctionContext): Promise<Response> => {
  const { request, env } = context as FunctionContext & { env: Env };
  const userId = String(context.data.userId ?? '');
  const db: D1Database = env.DB;

  const contentLength = Number(request.headers.get('Content-Length') ?? '0');
  if (contentLength > MAX_PAYLOAD_BYTES) {
    return jsonError(413, 'PAYLOAD_TOO_LARGE', '同步数据过大，请减少单批行数');
  }

  const body = await readJsonBody(request);
  if (body === null) {
    return jsonError(400, 'VALIDATION_ERROR', '请求格式不正确');
  }
  const changes = body.changes !== null && typeof body.changes === 'object' && !Array.isArray(body.changes)
    ? (body.changes as Record<string, unknown>)
    : null;
  if (changes === null) {
    return jsonError(400, 'VALIDATION_ERROR', '缺少 changes 字段');
  }

  const serverNow = Date.now();
  const serverNowIso = new Date(serverNow).toISOString();
  const syncedAt = serverNow;

  const accepted: string[] = [];
  const conflicts: string[] = [];
  const rejected: Array<{ id: string; reason: string }> = [];
  const statements: D1PreparedStatement[] = [];

  try {
    for (const spec of TABLE_SPECS) {
      const rawRows = changes[spec.key];
      if (rawRows === undefined || rawRows === null) {
        continue; // 字段可缺省，视为空集
      }
      if (!Array.isArray(rawRows)) {
        return jsonError(400, 'VALIDATION_ERROR', `changes.${spec.key} 必须是数组`);
      }

      for (const rawRow of rawRows) {
        if (rawRow === null || typeof rawRow !== 'object' || Array.isArray(rawRow)) {
          rejected.push({ id: '', reason: 'VALIDATION_ERROR' });
          continue;
        }
        const row = rawRow as Record<string, unknown>;
        const rowId = compositeRowId(row, spec);

        const pkExtract = extractFields(row, spec.pk, true);
        if (pkExtract.error !== undefined) {
          rejected.push({ id: rowId, reason: 'VALIDATION_ERROR' });
          continue;
        }
        if (typeof row.updatedAt !== 'string' || Number.isNaN(Date.parse(row.updatedAt))) {
          rejected.push({ id: rowId, reason: 'VALIDATION_ERROR:updatedAt' });
          continue;
        }
        const dataExtract = extractFields(row, spec.data);
        if (dataExtract.error !== undefined) {
          rejected.push({ id: rowId, reason: 'VALIDATION_ERROR' });
          continue;
        }

        const incomingUpdatedAt = clampUpdatedAt(row.updatedAt, serverNowIso);
        const isDeleted = row.isDeleted === true ? 1 : 0;
        const pkValues = pkExtract.values;

        // 按（复合）主键查现有行；只允许覆盖属于本人 user_id 的行。
        const pkCondition = spec.pk.map((field) => `${field.column} = ?`).join(' AND ');
        const existing = await db
          .prepare(`SELECT user_id, updated_at FROM ${spec.table} WHERE ${pkCondition} LIMIT 1`)
          .bind(...pkValues)
          .first<{ user_id: string; updated_at: string }>();

        if (existing === null) {
          // INSERT：服务端盖章 user_id / synced_at；created_at 取客户端值
          // （缺失或非法时回落到本次 updated_at，保证 NOT NULL 约束不失败）。
          const createdAtIso = typeof row.createdAt === 'string'
            && !Number.isNaN(Date.parse(row.createdAt))
            ? row.createdAt
            : incomingUpdatedAt;
          const columns = [
            ...spec.pk.map((field) => field.column),
            ...spec.data.map((field) => field.column),
            ...(spec.hasCreatedAt === true ? ['created_at'] : []),
            'user_id',
            'updated_at',
            'synced_at',
            'is_deleted',
          ];
          const values = [
            ...pkValues,
            ...dataExtract.values,
            ...(spec.hasCreatedAt === true ? [createdAtIso] : []),
            userId,
            incomingUpdatedAt,
            syncedAt,
            isDeleted,
          ];
          const placeholders = columns.map(() => '?').join(', ');
          statements.push(
            db.prepare(`INSERT INTO ${spec.table} (${columns.join(', ')}) VALUES (${placeholders})`).bind(...values),
          );
          accepted.push(rowId);
        } else if (existing.user_id !== userId) {
          // 同 id 但归属他人：绝不覆盖（理论上有 UUID 碰撞时保护数据）
          rejected.push({ id: rowId, reason: 'FORBIDDEN' });
        } else if (incomingUpdatedAt > existing.updated_at) {
          // LWW：客户端时间较新，覆盖
          const assignments = [
            ...spec.data.map((field) => `${field.column} = ?`),
            'user_id = ?',
            'updated_at = ?',
            'synced_at = ?',
            'is_deleted = ?',
          ];
          const values = [...dataExtract.values, userId, incomingUpdatedAt, syncedAt, isDeleted, ...pkValues];
          statements.push(
            db.prepare(`UPDATE ${spec.table} SET ${assignments.join(', ')} WHERE ${pkCondition}`).bind(...values),
          );
          accepted.push(rowId);
        } else {
          // 服务端更新：跳过并通知客户端回滚本地行
          conflicts.push(rowId);
        }
      }
    }

    // 统一事务提交（D1 batch 原子执行）
    if (statements.length > 0) {
      await db.batch(statements);
    }
  } catch (error) {
    // 保留原始错误信息用于线上排障（不含堆栈/密钥）；客户端只按 code 处理。
    const detail = error instanceof Error ? error.message : String(error);
    return jsonError(500, 'INTERNAL', `服务端异常：${detail}`);
  }

  return jsonOk({
    serverTime: serverNow,
    accepted,
    conflicts,
    rejected,
  });
};
