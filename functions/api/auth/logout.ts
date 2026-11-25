/**
 * POST /api/auth/logout —— 登出（架构 §4.5）：吊销 refreshToken。
 */

import { revokeRefreshTokenByHash, sha256Hex } from '../_lib/db';
import { jsonOk, readJsonBody } from '../_lib/json';
import type { Env, FunctionContext } from '../_lib/types';

export const onRequestPost = async (context: FunctionContext): Promise<Response> => {
  const { request, env } = context as FunctionContext & { env: Env };

  const body = await readJsonBody(request);
  const refreshToken = body !== null && typeof body.refreshToken === 'string'
    ? body.refreshToken.trim()
    : '';
  // 登出尽力而为：token 缺失/无效也返回成功（幂等），客户端清本地态即可。
  if (refreshToken.length > 0) {
    const tokenHash = await sha256Hex(refreshToken);
    await revokeRefreshTokenByHash(env.DB, tokenHash);
  }
  return jsonOk({});
};
