/**
 * POST /api/ai/* —— 智谱（BigModel）API 同域代理（Web 端专用）。
 *
 * 背景：`open.bigmodel.cn` 的响应不带 `Access-Control-Allow-Origin`，
 * 浏览器直连会在预检阶段被拦截（客户端只能看到 `Failed to fetch`，
 * 表现为「网络异常」）。手机 App 是原生 HTTP，不受此限制。
 *
 * 本代理只做一件事：把请求原样转发到智谱官方端点，并把响应原样返回，
 * 让 Web 端通过同域路径（savesave.pages.dev/api/ai/*）规避 CORS。
 *
 * 安全与隐私边界（务必保持不变）：
 * - 本代理**不落库、不记录** Authorization（API Key）与请求/响应正文；
 * - 仅允许转发到 `open.bigmodel.cn`，路径限制在 `/api/paas/v4/` 白名单内，
 *   避免被当作任意地址的开放代理；
 * - 不校验登录态（AI 功能在游客模式亦可使用，Key 由用户自带），
 *   改用按 IP 的速率限制防滥用。
 */

import { jsonError, corsHeaders } from '../_lib/json';
import type { Env, FunctionContext } from '../_lib/types';

/** 允许转发的上游路径白名单（相对 /api/paas/v4/）。 */
const ALLOWED_PATHS = new Set<string>([
  'chat/completions',
  'embeddings',
]);

const UPSTREAM_ORIGIN = 'https://open.bigmodel.cn';
const UPSTREAM_PREFIX = '/api/paas/v4/';

/** 按 IP 的调用上限：每 15 分钟 200 次（正常使用远低于此）。 */
const RATE_LIMIT = 200;
const RATE_WINDOW_MS = 15 * 60 * 1000;

/**
 * 与同域 JWT 接口无关的轻量限流（复用 rate_limits 表，key 前缀区分）。
 * 失败时放行——限流不应成为可用性单点。
 */
async function allowByRateLimit(db: Env['DB'] | undefined, ip: string): Promise<boolean> {
  if (db === undefined || typeof db.prepare !== 'function') {
    return true;
  }
  const key = `ai:${ip}`;
  const now = Date.now();
  try {
    const existing = await db
      .prepare('SELECT count, window_start FROM rate_limits WHERE key = ?')
      .bind(key)
      .first<{ count: number; window_start: number }>();
    if (existing === null || now - existing.window_start >= RATE_WINDOW_MS) {
      await db
        .prepare(
          'INSERT INTO rate_limits (key, count, window_start) VALUES (?, 1, ?) '
          + 'ON CONFLICT(key) DO UPDATE SET count = 1, window_start = ?',
        )
        .bind(key, now, now)
        .run();
      return true;
    }
    if (existing.count >= RATE_LIMIT) {
      return false;
    }
    await db.prepare('UPDATE rate_limits SET count = count + 1 WHERE key = ?').bind(key).run();
    return true;
  } catch {
    return true;
  }
}

export const onRequestPost = async (context: FunctionContext): Promise<Response> => {
  const { request, env, params } = context as FunctionContext & {
    env: Env;
    params: { path?: string | string[] };
  };
  const cors = corsHeaders(request, env);

  const rawPath = Array.isArray(params.path) ? params.path.join('/') : (params.path ?? '');
  const path = rawPath.replace(/^\/+|\/+$/g, '');
  if (!ALLOWED_PATHS.has(path)) {
    return jsonError(404, 'NOT_FOUND', '不支持的 AI 接口路径', cors);
  }

  const ip = request.headers.get('CF-Connecting-IP') ?? 'local';
  if (!(await allowByRateLimit(env?.DB, ip))) {
    return jsonError(429, 'RATE_LIMITED', 'AI 调用过于频繁，请稍后再试', cors);
  }

  const body = await request.text();
  if (body.length > 4 * 1024 * 1024) {
    return jsonError(413, 'PAYLOAD_TOO_LARGE', '图片或请求体过大，请压缩后重试', cors);
  }

  // API Key 由客户端以 Authorization 头传入，原样转给智谱，本代理不解析不落盘。
  const headers = new Headers();
  headers.set('Content-Type', 'application/json');
  const authorization = request.headers.get('Authorization');
  if (authorization !== null && authorization.length > 0) {
    headers.set('Authorization', authorization);
  }

  let upstream: Response;
  try {
    upstream = await fetch(`${UPSTREAM_ORIGIN}${UPSTREAM_PREFIX}${path}`, {
      method: 'POST',
      headers,
      body,
    });
  } catch (error) {
    const detail = error instanceof Error ? error.message : String(error);
    return jsonError(502, 'UPSTREAM_UNREACHABLE', `模型服务连接失败：${detail}`, cors);
  }

  // 原样透传状态码与正文；只补 CORS 头（同域其实不需要，但便于本地调试）。
  const responseHeaders = new Headers(upstream.headers);
  responseHeaders.delete('set-cookie');
  for (const [key, value] of Object.entries(cors)) {
    responseHeaders.set(key, value);
  }
  return new Response(upstream.body, {
    status: upstream.status,
    headers: responseHeaders,
  });
};

/** 非 POST 一律 405，避免被当作下载/预取目标。 */
export const onRequest = async (context: FunctionContext): Promise<Response> => {
  const cors = corsHeaders(context.request, (context as FunctionContext & { env: Env }).env);
  if (context.request.method === 'OPTIONS') {
    return new Response(null, { status: 204, headers: cors });
  }
  return jsonError(405, 'METHOD_NOT_ALLOWED', '仅支持 POST', cors);
};
