/**
 * D1 数据访问与账号辅助（users / refresh_tokens / rate_limits）。
 * 全部查询强制带归属条件；refresh token 原文不落库（只存 sha256）。
 */

import type { D1Database } from './types';

/** 会话令牌对（登录/注册/刷新统一返回结构，架构 §4.2）。 */
export interface TokenPair {
  user: { id: string; email: string; nickname: string };
  accessToken: string;
  refreshToken: string;
  expiresIn: number;
}

/** refreshToken 有效期：30 天（毫秒）。 */
export const REFRESH_TTL_MS = 30 * 24 * 60 * 60 * 1000;

/** 限流窗口：15 分钟。 */
const RATE_WINDOW_MS = 15 * 60 * 1000;
/** 同 IP 窗口内上限（register 按纯 IP）。 */
const RATE_LIMIT_IP = 20;
/** 同 IP+邮箱 窗口内上限。 */
const RATE_LIMIT_KEY = 8;

export function nowIsoUtc(): string {
  return new Date().toISOString();
}

/** 生成服务端 uuid。 */
export function newUserId(): string {
  return crypto.randomUUID();
}

/** SHA-256 hex（用于 refresh token 落库前哈希）。 */
export async function sha256Hex(text: string): Promise<string> {
  const digest = await crypto.subtle.digest(
    'SHA-256',
    new TextEncoder().encode(text),
  );
  return Array.from(new Uint8Array(digest))
    .map((byte) => byte.toString(16).padStart(2, '0'))
    .join('');
}

/** 生成 256bit 随机 refreshToken（hex 编码）。 */
export function newRefreshToken(): string {
  const bytes = crypto.getRandomValues(new Uint8Array(32));
  return Array.from(bytes)
    .map((byte) => byte.toString(16).padStart(2, '0'))
    .join('');
}

/**
 * 滑动窗口限流检查（简化为固定 15 分钟窗口计数，架构 §4.1）。
 * 命中上限返回 false；未超限计数 +1。
 */
export async function checkRateLimit(
  db: D1Database,
  kind: 'login' | 'register',
  ip: string,
  emailHash: string,
): Promise<boolean> {
  const key = kind === 'register'
    ? `register:${ip}`
    : `login:${ip}:${emailHash}`;
  const limit = kind === 'register' ? RATE_LIMIT_IP : RATE_LIMIT_KEY;
  const now = Date.now();
  const existing = await db
    .prepare('SELECT count, window_start FROM rate_limits WHERE key = ?')
    .bind(key)
    .first<{ count: number; window_start: number }>();
  if (!existing || now - existing.window_start >= RATE_WINDOW_MS) {
    await db
      .prepare(
        'INSERT INTO rate_limits (key, count, window_start) VALUES (?, 1, ?) '
        + 'ON CONFLICT(key) DO UPDATE SET count = 1, window_start = ?',
      )
      .bind(key, now, now)
      .run();
    return true;
  }
  if (existing.count >= limit) {
    return false;
  }
  await db
    .prepare('UPDATE rate_limits SET count = count + 1 WHERE key = ?')
    .bind(key)
    .run();
  return true;
}

export interface UserRow {
  id: string;
  email: string;
  password_hash: string;
  nickname: string;
  created_at: string;
  updated_at: string;
  is_deleted: number;
}

/** 按邮箱查用户（调用方自行决定是否校验 is_deleted）。 */
export async function findUserByEmail(
  db: D1Database,
  email: string,
): Promise<UserRow | null> {
  return db
    .prepare('SELECT * FROM users WHERE email = ? LIMIT 1')
    .bind(email)
    .first<UserRow>();
}

/** 创建用户并签发首个会话（注册用，单事务）。 */
export async function createUserWithSession(
  db: D1Database,
  params: {
    email: string;
    passwordHash: string;
    nickname: string;
  },
  tokens: { accessToken: string; refreshTokenHash: string; refreshTokenExpiresAt: number },
): Promise<TokenPair['user']> {
  const id = newUserId();
  const now = nowIsoUtc();
  await db.batch([
    db
      .prepare(
        'INSERT INTO users (id, email, password_hash, nickname, created_at, updated_at, is_deleted) '
        + 'VALUES (?, ?, ?, ?, ?, ?, 0)',
      )
      .bind(id, params.email, params.passwordHash, params.nickname, now, now),
    db
      .prepare(
        'INSERT INTO refresh_tokens (id, user_id, token_hash, expires_at, revoked, created_at) '
        + 'VALUES (?, ?, ?, ?, 0, ?)',
      )
      .bind(crypto.randomUUID(), id, tokens.refreshTokenHash, tokens.refreshTokenExpiresAt, Date.now()),
  ]);
  return { id, email: params.email, nickname: params.nickname };
}

/** 为既有用户创建新会话（登录/刷新用）。 */
export async function issueSession(
  db: D1Database,
  user: { id: string; email: string; nickname: string },
  tokens: { accessToken: string; refreshTokenHash: string; refreshTokenExpiresAt: number },
): Promise<void> {
  await db
    .prepare(
      'INSERT INTO refresh_tokens (id, user_id, token_hash, expires_at, revoked, created_at) '
      + 'VALUES (?, ?, ?, ?, 0, ?)',
    )
    .bind(crypto.randomUUID(), user.id, tokens.refreshTokenHash, tokens.refreshTokenExpiresAt, Date.now())
    .run();
}

export interface RefreshTokenRow {
  id: string;
  user_id: string;
  token_hash: string;
  expires_at: number;
  revoked: number;
}

/** 按 id 查用户（刷新会话时取最新资料）。 */
export async function findUserById(
  db: D1Database,
  id: string,
): Promise<UserRow | null> {
  return db
    .prepare('SELECT * FROM users WHERE id = ? LIMIT 1')
    .bind(id)
    .first<UserRow>();
}

/** 按 sha256 查找未过期未吊销的 refreshToken。 */
export async function findLiveRefreshToken(
  db: D1Database,
  tokenHash: string,
): Promise<RefreshTokenRow | null> {
  const row = await db
    .prepare('SELECT * FROM refresh_tokens WHERE token_hash = ? LIMIT 1')
    .bind(tokenHash)
    .first<RefreshTokenRow>();
  if (!row || row.revoked !== 0 || Date.now() >= row.expires_at) {
    return null;
  }
  return row;
}

/** 简化版 rotation：吊销旧 refreshToken。 */
export async function revokeRefreshTokenById(
  db: D1Database,
  id: string,
): Promise<void> {
  await db
    .prepare('UPDATE refresh_tokens SET revoked = 1 WHERE id = ?')
    .bind(id)
    .run();
}

/** 登出：按原文哈希吊销。 */
export async function revokeRefreshTokenByHash(
  db: D1Database,
  tokenHash: string,
): Promise<void> {
  await db
    .prepare('UPDATE refresh_tokens SET revoked = 1 WHERE token_hash = ?')
    .bind(tokenHash)
    .run();
}
