/**
 * /api/* 统一中间件：CORS 预检 + JWT 鉴权（架构 §5.2）。
 *
 * - `/api/auth/*`、`/api/health` 免鉴权；
 * - 其余路由（/api/sync/*）必须携带 `Authorization: Bearer <accessToken>`；
 * - 校验通过后把 userId 写入 context.data，供下游业务使用（服务端盖章来源）。
 */

import { corsHeaders, jsonError, preflightResponse } from './_lib/json';
import { verifyJwt } from './_lib/jwt';
import type { Env, FunctionContext } from './_lib/types';

export const onRequest = async (context: FunctionContext): Promise<Response> => {
  const { request, env } = context;
  const url = new URL(request.url);
  const path = url.pathname;
  const cors = corsHeaders(request, env);

  // 1) CORS 预检统一应答
  if (request.method === 'OPTIONS') {
    return preflightResponse(cors);
  }

  // 2) 免鉴权路由：健康检查、认证、以及 BYOK 的 AI 代理
  //    （AI 为自带 Key 能力，游客模式也要能用；该路径自身按 IP 限流）
  const isExempt = path === '/api/health'
    || path.startsWith('/api/auth/')
    || path.startsWith('/api/ai/');
  if (!isExempt) {
    const authHeader = request.headers.get('Authorization') ?? '';
    const bearer = authHeader.startsWith('Bearer ') ? authHeader.slice(7).trim() : '';
    if (bearer.length === 0) {
      return jsonError(401, 'UNAUTHORIZED', '请先登录', cors);
    }
    const payload = await verifyJwt(bearer, env.JWT_SECRET);
    if (payload === null) {
      // 非法与过期统一按 TOKEN_EXPIRED 返回：客户端收到 401 后走
      // 单飞刷新（架构 §5.3），刷新失败（REFRESH_INVALID）再踢回登录页。
      return jsonError(401, 'TOKEN_EXPIRED', '登录已过期，请重新登录', cors);
    }
    context.data.userId = payload.sub;
  }

  let response: Response;
  try {
    response = await context.next();
  } catch (error) {
    // 兜底：把未捕获异常转成结构化错误，避免直接抛出 1101，
    // 同时保留 msg 便于线上排障（不含堆栈与密钥内容）。
    const message = error instanceof Error ? error.message : String(error);
    response = jsonError(500, 'INTERNAL_ERROR', `服务端异常：${message}`, cors);
  }
  // 3) 为所有响应追加 CORS 头（白名单内来源）
  for (const [key, value] of Object.entries(cors)) {
    response.headers.set(key, value);
  }
  return response;
};
