/**
 * POST /api/auth/refresh —— 会话续期（架构 §4.4）。
 *
 * 校验 D1 refresh_tokens（未过期未吊销）→ 简化版 rotation：
 * 吊销旧 refreshToken，签发新 token 对。
 */

import {
  findLiveRefreshToken,
  findUserById,
  issueSession,
  newRefreshToken,
  REFRESH_TTL_MS,
  revokeRefreshTokenById,
  sha256Hex,
} from '../_lib/db';
import { signJwt } from '../_lib/jwt';
import { jsonError, jsonOk, readJsonBody } from '../_lib/json';
import type { Env, FunctionContext } from '../_lib/types';

export const onRequestPost = async (context: FunctionContext): Promise<Response> => {
  const { request, env } = context as FunctionContext & { env: Env };

  const body = await readJsonBody(request);
  const refreshToken = body !== null && typeof body.refreshToken === 'string'
    ? body.refreshToken.trim()
    : '';
  if (refreshToken.length === 0) {
    return jsonError(400, 'VALIDATION_ERROR', '缺少 refreshToken');
  }

  const tokenHash = await sha256Hex(refreshToken);
  const row = await findLiveRefreshToken(env.DB, tokenHash);
  if (row === null) {
    return jsonError(401, 'REFRESH_INVALID', '登录已失效，请重新登录');
  }

  const user = await findUserById(env.DB, row.user_id);
  if (user === null || user.is_deleted !== 0) {
    return jsonError(401, 'REFRESH_INVALID', '登录已失效，请重新登录');
  }

  // 简化版 rotation：旧 token 吊销，只允许携带最新 token 的设备续期成功。
  await revokeRefreshTokenById(env.DB, row.id);

  const newRefreshTokenValue = newRefreshToken();
  const newHash = await sha256Hex(newRefreshTokenValue);
  await issueSession(
    env.DB,
    { id: user.id, email: user.email, nickname: user.nickname },
    { refreshTokenHash: newHash, refreshTokenExpiresAt: Date.now() + REFRESH_TTL_MS },
  );
  const accessToken = await signJwt({ sub: user.id }, env.JWT_SECRET);

  return jsonOk({
    user: { id: user.id, email: user.email, nickname: user.nickname },
    accessToken,
    refreshToken: newRefreshTokenValue,
    expiresIn: 7200,
  });
};
