/**
 * POST /api/auth/login —— 云端登录（架构 §4.3）。
 *
 * 401 统一文案「邮箱或密码不正确」（防撞库）；限流同注册。
 */

import {
  checkRateLimit,
  findUserByEmail,
  issueSession,
  newRefreshToken,
  REFRESH_TTL_MS,
  sha256Hex,
} from '../_lib/db';
import { verifyPassword } from '../_lib/password';
import { signJwt } from '../_lib/jwt';
import { jsonError, jsonOk, readJsonBody } from '../_lib/json';
import type { Env, FunctionContext } from '../_lib/types';

export const onRequestPost = async (context: FunctionContext): Promise<Response> => {
  const { request, env } = context as FunctionContext & { env: Env };

  const body = await readJsonBody(request);
  if (body === null) {
    return jsonError(400, 'VALIDATION_ERROR', '请求格式不正确');
  }

  const rawEmail = typeof body.email === 'string' ? body.email.trim().toLowerCase() : '';
  const password = typeof body.password === 'string' ? body.password : '';
  if (rawEmail.length === 0 || password.length === 0) {
    return jsonError(400, 'VALIDATION_ERROR', '请输入邮箱和密码');
  }

  const ip = request.headers.get('CF-Connecting-IP') ?? 'local';
  const emailHash = await sha256Hex(rawEmail);
  const allowed = await checkRateLimit(env.DB, 'login', ip, emailHash);
  if (!allowed) {
    return jsonError(429, 'RATE_LIMITED', '登录尝试过于频繁，请 15 分钟后再试');
  }

  const user = await findUserByEmail(env.DB, rawEmail);
  const ok = user !== null
    && user.is_deleted === 0
    && await verifyPassword(password, user.password_hash);
  if (!ok || user === null) {
    return jsonError(401, 'INVALID_CREDENTIALS', '邮箱或密码不正确');
  }

  const refreshToken = newRefreshToken();
  const refreshTokenHash = await sha256Hex(refreshToken);
  await issueSession(
    env.DB,
    { id: user.id, email: user.email, nickname: user.nickname },
    { refreshTokenHash, refreshTokenExpiresAt: Date.now() + REFRESH_TTL_MS },
  );
  const accessToken = await signJwt({ sub: user.id }, env.JWT_SECRET);

  return jsonOk({
    user: { id: user.id, email: user.email, nickname: user.nickname },
    accessToken,
    refreshToken,
    expiresIn: 7200,
  });
};
