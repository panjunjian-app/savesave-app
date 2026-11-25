/**
 * 响应包裹与 CORS 工具。
 *
 * 统一包裹约定（架构 §4.1）：
 * - 成功：`{"code":0,"data":{...}}`
 * - 失败：`{"code":"<错误码>","message":"<中文提示>"}`
 */

import type { Env } from './types';

/** 通用成功响应体。 */
export function jsonOk(
  data: Record<string, unknown>,
  status = 200,
  cors?: Record<string, string>,
): Response {
  return new Response(JSON.stringify({ code: 0, data }), {
    status,
    headers: { 'Content-Type': 'application/json; charset=utf-8', ...(cors ?? {}) },
  });
}

/** 通用错误响应体。`message` 一律中文，且不含内部细节（日志脱敏由调用方保证）。 */
export function jsonError(
  httpStatus: number,
  code: string,
  message: string,
  cors?: Record<string, string>,
): Response {
  return new Response(JSON.stringify({ code, message }), {
    status: httpStatus,
    headers: { 'Content-Type': 'application/json; charset=utf-8', ...(cors ?? {}) },
  });
}

/**
 * 计算本次请求的 CORS 响应头。
 * 规则（架构 §2）：同源（Web 端同域部署）天然免 CORS，不放头；
 * App 端跨域仅放行 env.ALLOWED_ORIGINS 白名单内的来源。
 */
export function corsHeaders(request: Request, env: Env): Record<string, string> {
  const origin = request.headers.get('Origin');
  if (!origin) {
    return {};
  }
  const whitelist = (env.ALLOWED_ORIGINS ?? '')
    .split(',')
    .map((item) => item.trim())
    .filter(Boolean);
  if (!whitelist.includes(origin)) {
    return {};
  }
  return {
    'Access-Control-Allow-Origin': origin,
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    'Access-Control-Max-Age': '86400',
    Vary: 'Origin',
  };
}

/** CORS 预检快速应答（由 _middleware 统一拦截 OPTIONS）。 */
export function preflightResponse(cors: Record<string, string>): Response {
  return new Response(null, { status: 204, headers: cors });
}

/** 请求体 JSON 解析：任何异常都归一为 null，由调用方报 VALIDATION_ERROR。 */
export async function readJsonBody(request: Request): Promise<Record<string, unknown> | null> {
  try {
    const raw = await request.json();
    return raw && typeof raw === 'object' && !Array.isArray(raw)
      ? (raw as Record<string, unknown>)
      : null;
  } catch {
    return null;
  }
}
