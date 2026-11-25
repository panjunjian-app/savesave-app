/**
 * JWT（HS256）签发与校验 —— 纯 Web Crypto 实现，零第三方依赖（架构 §5.2）。
 *
 * - Header：`{"alg":"HS256","typ":"JWT"}`
 * - Payload：`{"sub":"<user_id>","iat":<ms>,"exp":<iat+7200s>,"typ":"access"}`
 *   注意：iat/exp 单位为毫秒（与本仓库客户端约定一致，非 RFC 的秒）。
 * - secret 由 wrangler secret `JWT_SECRET` 注入，绝不落库/落日志。
 */

const HEADER_B64 = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'; // {"alg":"HS256","typ":"JWT"} 的 base64url

/** accessToken 有效期：2 小时（毫秒）。 */
export const ACCESS_TOKEN_TTL_MS = 2 * 60 * 60 * 1000;

export interface JwtPayload {
  sub: string;
  iat: number;
  exp: number;
  typ: 'access';
}

/** 标准 base64url（RFC 4648 §5，无填充）。 */
function base64UrlEncode(bytes: Uint8Array): string {
  let binary = '';
  for (const byte of bytes) {
    binary += String.fromCharCode(byte);
  }
  return btoa(binary).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
}

/** base64url 解码为字节。 */
function base64UrlDecode(text: string): Uint8Array {
  const normalized = text.replace(/-/g, '+').replace(/_/g, '/');
  const padded = normalized + '='.repeat((4 - (normalized.length % 4)) % 4);
  const binary = atob(padded);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) {
    bytes[i] = binary.charCodeAt(i);
  }
  return bytes;
}

function utf8Encode(text: string): Uint8Array {
  return new TextEncoder().encode(text);
}

/** HMAC-SHA256 原始签名。 */
async function hmacSha256(secret: string, data: Uint8Array): Promise<Uint8Array> {
  const key = await crypto.subtle.importKey(
    'raw',
    utf8Encode(secret),
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign'],
  );
  const signature = await crypto.subtle.sign('HMAC', key, data as unknown as ArrayBuffer);
  return new Uint8Array(signature);
}

/** 恒定时间比较，防时序侧信道。 */
export function constantTimeEqual(a: string, b: string): boolean {
  if (a.length !== b.length) {
    return false;
  }
  let diff = 0;
  for (let i = 0; i < a.length; i++) {
    diff |= a.charCodeAt(i) ^ b.charCodeAt(i);
  }
  return diff === 0;
}

/** 签发 accessToken。 */
export async function signJwt(
  payload: Pick<JwtPayload, 'sub'>,
  secret: string,
  nowMs = Date.now(),
): Promise<string> {
  const body: JwtPayload = {
    sub: payload.sub,
    iat: nowMs,
    exp: nowMs + ACCESS_TOKEN_TTL_MS,
    typ: 'access',
  };
  const payloadB64 = base64UrlEncode(utf8Encode(JSON.stringify(body)));
  const signingInput = `${HEADER_B64}.${payloadB64}`;
  const signature = await hmacSha256(secret, utf8Encode(signingInput));
  return `${signingInput}.${base64UrlEncode(signature)}`;
}

/** 校验 accessToken：签名、格式、过期、typ。非法返回 null。 */
export async function verifyJwt(token: string, secret: string): Promise<JwtPayload | null> {
  const parts = token.split('.');
  if (parts.length !== 3) {
    return null;
  }
  const [headerB64, payloadB64, signatureB64] = parts;
  if (headerB64 !== HEADER_B64) {
    return null;
  }
  const expected = await hmacSha256(secret, utf8Encode(`${headerB64}.${payloadB64}`));
  if (!constantTimeEqual(base64UrlEncode(expected), signatureB64)) {
    return null;
  }
  let payload: JwtPayload;
  try {
    payload = JSON.parse(new TextDecoder().decode(base64UrlDecode(payloadB64))) as JwtPayload;
  } catch {
    return null;
  }
  if (payload.typ !== 'access' || typeof payload.sub !== 'string' || payload.sub.length === 0) {
    return null;
  }
  if (typeof payload.exp !== 'number' || Date.now() >= payload.exp) {
    return null;
  }
  return payload;
}
