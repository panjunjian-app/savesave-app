/**
 * POST /api/sync/pull —— 增量拉取（架构 §4.6）。
 *
 * - 需鉴权：userId 由中间件盖章进 context.data；
 * - `since` 为客户端上次记录的服务端 synced_at 水位（首次传 0 即全量）；
 * - 每表 ≤500 行，任一表截断则 hasMore=true，客户端用本批最大 synced_at 续拉；
 * - user_id 条件强制，杜绝水平越权（S5）。
 */

import { jsonError, jsonOk, readJsonBody } from '../_lib/json';
import type { Env, FunctionContext } from '../_lib/types';

/** 单次每表最大行数（PRD S9：分页 ≤500 行）。 */
const PAGE_LIMIT = 500;

export const onRequestPost = async (context: FunctionContext): Promise<Response> => {
  const { request, env } = context as FunctionContext & { env: Env };
  const userId = String(context.data.userId ?? '');

  const body = await readJsonBody(request);
  if (body === null) {
    return jsonError(400, 'VALIDATION_ERROR', '请求格式不正确');
  }
  const since = typeof body.since === 'number' && Number.isFinite(body.since) && body.since >= 0
    ? Math.floor(body.since)
    : 0;
  const limit = typeof body.limit === 'number' && body.limit > 0 && body.limit <= PAGE_LIMIT
    ? Math.floor(body.limit)
    : PAGE_LIMIT;

  // 每表独立增量查询；查询比 limit 多取一行以判断 hasMore。
  // synced_at 一并返回：hasMore 时客户端用「本批最大 synced_at」续拉（架构 §4.6）。
  const tables: Array<{ key: string; sql: string }> = [
    { key: 'ledgers', sql: 'SELECT id, name, icon, color, sort_order, created_at, updated_at, is_deleted, synced_at FROM ledgers WHERE user_id = ? AND synced_at > ? ORDER BY synced_at LIMIT ?' },
    { key: 'bills', sql: 'SELECT id, ledger_id, category_id, type, amount_cents, bill_date, note, source, created_at, updated_at, is_deleted, synced_at FROM bills WHERE user_id = ? AND synced_at > ? ORDER BY synced_at LIMIT ?' },
    { key: 'categories', sql: 'SELECT id, name, type, icon, color, is_custom, sort_order, updated_at, is_deleted, synced_at FROM categories WHERE user_id = ? AND synced_at > ? ORDER BY synced_at LIMIT ?' },
    { key: 'savingsGoals', sql: 'SELECT id, name, target_amount_cents, deadline, icon, theme_color, note, status, created_at, updated_at, is_deleted, synced_at FROM savings_goals WHERE user_id = ? AND synced_at > ? ORDER BY synced_at LIMIT ?' },
    { key: 'goalLedgerBindings', sql: 'SELECT goal_id, ledger_id, created_at, updated_at, is_deleted, synced_at FROM goal_ledger_bindings WHERE user_id = ? AND synced_at > ? ORDER BY synced_at LIMIT ?' },
    { key: 'goalMilestones', sql: 'SELECT goal_id, threshold_pct, first_reached_date, updated_at, is_deleted, synced_at FROM goal_milestones WHERE user_id = ? AND synced_at > ? ORDER BY synced_at LIMIT ?' },
    { key: 'aiAnalysisReports', sql: 'SELECT id, scope_period_type, scope_period_label, scope_ledger_key, scope_anchor_date, report_json, data_version, created_at, updated_at, expires_at, is_stale, goal_key, model_id, consent_version, synced_at FROM ai_analysis_reports WHERE user_id = ? AND synced_at > ? ORDER BY synced_at LIMIT ?' },
  ];

  const rowToCamel = (row: Record<string, unknown>): Record<string, unknown> => {
    const out: Record<string, unknown> = {};
    for (const [key, value] of Object.entries(row)) {
      // snake_case → camelCase（同步字段的机械映射，架构 §3）
      out[key.replace(/_([a-z])/g, (_m, c: string) => c.toUpperCase())] = value;
    }
    return out;
  };

  const changes: Record<string, unknown[]> = {};
  let hasMore = false;
  try {
    for (const table of tables) {
      const result = await env.DB
        .prepare(table.sql)
        .bind(userId, since, limit + 1)
        .all<Record<string, unknown>>();
      const rows = result.results ?? [];
      if (rows.length > limit) {
        hasMore = true;
        changes[table.key] = rows.slice(0, limit).map(rowToCamel);
      } else {
        changes[table.key] = rows.map((row) => {
          const camel = rowToCamel(row);
          // D1 的 is_deleted 是 INTEGER(0/1)，客户端按布尔解码（删除传播），
          // 这里统一转成真正的 boolean，避免 0/1 被误判为「未删除」。
          if ('isDeleted' in camel) {
            camel.isDeleted = camel.isDeleted === 1 || camel.isDeleted === true;
          }
          return camel;
        });
      }
    }
  } catch {
    return jsonError(500, 'INTERNAL', '服务端异常，请稍后重试');
  }

  return jsonOk({
    serverTime: Date.now(),
    hasMore,
    changes,
  });
};
