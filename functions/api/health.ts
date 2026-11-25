/**
 * GET /api/health —— 探活接口（免鉴权）。
 * 用于客户端「云端不可用自动降级为纯本地模式」（PRD S10）的探活。
 *
 * 同时暴露部署自检信息（仅布尔值，不泄露任何密钥内容）：
 * - db: D1 绑定是否可用
 * - jwt: JWT_SECRET 是否已注入
 * - schema: users/rate_limits 表是否就绪
 */

import { jsonOk } from './_lib/json';
import type { Env, FunctionContext } from './_lib/types';

export const onRequest = async (context: FunctionContext): Promise<Response> => {
  const env = (context as FunctionContext & { env: Env }).env;
  const dbBound = typeof env?.DB?.prepare === 'function';
  let schemaReady = false;
  let dbError: string | null = null;
  if (dbBound) {
    try {
      const row = await env.DB.prepare(
        "SELECT COUNT(*) AS n FROM sqlite_master WHERE type='table' AND name IN ('users','rate_limits','refresh_tokens')",
      ).first<{ n: number }>();
      schemaReady = (row?.n ?? 0) === 3;
    } catch (error) {
      dbError = error instanceof Error ? error.message : String(error);
    }
  }
  return jsonOk({
    status: dbBound && schemaReady ? 'ok' : 'degraded',
    time: Date.now(),
    db: dbBound,
    schema: schemaReady,
    jwt: typeof (env as unknown as { JWT_SECRET?: string })?.JWT_SECRET === 'string',
    dbError,
  });
};
