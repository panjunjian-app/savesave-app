/**
 * POST /api/auth/register —— 云端注册（架构 §4.2）。
 *
 * 流程：格式校验（密码 ≥8 位）→ 限流 → 查重（409）→ PBKDF2 哈希
 * → 建号 + 首个 refreshToken → 返回 token 对（201）。
 */

import {
  checkRateLimit,
  createUserWithSession,
  newRefreshToken,
  REFRESH_TTL_MS,
  sha256Hex,
} from '../_lib/db';
import { hashPassword } from '../_lib/password';
import { signJwt } from '../_lib/jwt';
import { jsonError, jsonOk, readJsonBody } from '../_lib/json';
import type { Env, FunctionContext } from '../_lib/types';

const EMAIL_PATTERN = /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/;

export const onRequestPost = async (context: FunctionContext): Promise<Response> => {
  const { request, env } = context as FunctionContext & { env: Env };

  const body = await readJsonBody(request);
  if (body === null) {
    return jsonError(400, 'VALIDATION_ERROR', '请求格式不正确');
  }

  const rawEmail = typeof body.email === 'string' ? body.email.trim().toLowerCase() : '';
  const password = typeof body.password === 'string' ? body.password : '';
  const nickname = typeof body.nickname === 'string' && body.nickname.trim().length > 0
    ? body.nickname.trim().slice(0, 20)
    : '邮箱用户';

  if (rawEmail.length === 0 || rawEmail.length > 254 || !EMAIL_PATTERN.test(rawEmail)) {
    return jsonError(400, 'VALIDATION_ERROR', '邮箱格式不正确');
  }
  if (password.length < 8 || password.length > 64) {
    return jsonError(400, 'VALIDATION_ERROR', '密码至少 8 位，最多 64 位');
  }

  // 限流：同 IP 20 次（注册）/ 同 IP+邮箱 8 次，15 分钟窗口（架构 §4.1）
  const ip = request.headers.get('CF-Connecting-IP') ?? 'local';
  const emailHash = await sha256Hex(rawEmail);
  const allowed = await checkRateLimit(env.DB, 'register', ip, emailHash)
    && await checkRateLimit(env.DB, 'login', ip, emailHash);
  if (!allowed) {
    return jsonError(429, 'RATE_LIMITED', '操作过于频繁，请 15 分钟后再试');
  }

  const existing = await env.DB.prepare('SELECT id FROM users WHERE email = ? LIMIT 1')
    .bind(rawEmail)
    .first<{ id: string }>();
  if (existing !== null) {
    return jsonError(409, 'EMAIL_EXISTS', '该邮箱已注册，请直接登录');
  }

  const passwordHash = await hashPassword(password);
  const refreshToken = newRefreshToken();
  const refreshTokenHash = await sha256Hex(refreshToken);
  const user = await createUserWithSession(
    env.DB,
    { email: rawEmail, passwordHash, nickname },
    { refreshTokenHash, refreshTokenExpiresAt: Date.now() + REFRESH_TTL_MS },
  );
  const accessToken = await signJwt({ sub: user.id }, env.JWT_SECRET);

  return jsonOk(
    {
      user,
      accessToken,
      refreshToken,
      expiresIn: 7200,
    },
    201,
  );
};
