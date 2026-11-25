/**
 * JWT（HS256）签发/校验 + PBKDF2 密码格式 本地冒烟脚本。
 *
 * 用途：不起 Workers 真环境，验证 functions/api/_lib 同款算法在 Node ≥18
 * 的 Web Crypto 实现下行为正确（Node 18+ 内置 globalThis.crypto）。
 *
 * 运行：node scripts/jwt_smoke.mjs
 * 退出码 0 = 全部断言通过。
 */

import assert from 'node:assert/strict';

const HEADER_B64 = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'; // {"alg":"HS256","typ":"JWT"}
const ACCESS_TOKEN_TTL_MS = 2 * 60 * 60 * 1000;

const utf8 = new TextEncoder();

const b64urlEncode = (bytes) =>
  Buffer.from(bytes).toString('base64url');
const b64urlDecode = (text) => new Uint8Array(Buffer.from(text, 'base64url'));

async function hmac(secret, data) {
  const key = await crypto.subtle.importKey(
    'raw',
    utf8.encode(secret),
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign'],
  );
  return new Uint8Array(await crypto.subtle.sign('HMAC', key, data));
}

async function signJwt(sub, secret, nowMs) {
  const payload = { sub, iat: nowMs, exp: nowMs + ACCESS_TOKEN_TTL_MS, typ: 'access' };
  const payloadB64 = b64urlEncode(utf8.encode(JSON.stringify(payload)));
  const signingInput = `${HEADER_B64}.${payloadB64}`;
  const signature = await hmac(secret, utf8.encode(signingInput));
  return `${signingInput}.${b64urlEncode(signature)}`;
}

async function verifyJwt(token, secret) {
  const parts = token.split('.');
  if (parts.length !== 3) return null;
  const [headerB64, payloadB64, signatureB64] = parts;
  if (headerB64 !== HEADER_B64) return null;
  const expected = b64urlEncode(await hmac(secret, utf8.encode(`${headerB64}.${payloadB64}`)));
  // 恒定时间比较
  if (expected.length !== signatureB64.length) return null;
  let diff = 0;
  for (let i = 0; i < expected.length; i++) diff |= expected.charCodeAt(i) ^ signatureB64.charCodeAt(i);
  if (diff !== 0) return null;
  const payload = JSON.parse(new TextDecoder().decode(b64urlDecode(payloadB64)));
  if (payload.typ !== 'access' || !payload.sub) return null;
  if (Date.now() >= payload.exp) return null;
  return payload;
}

async function hashPassword(password) {
  const salt = crypto.getRandomValues(new Uint8Array(16));
  const key = await crypto.subtle.importKey('raw', utf8.encode(password), 'PBKDF2', false, ['deriveBits']);
  const bits = await crypto.subtle.deriveBits(
    { name: 'PBKDF2', hash: 'SHA-256', salt, iterations: 150000 },
    key,
    256,
  );
  return `pbkdf2_sha256$150000$${Buffer.from(salt).toString('base64')}$${Buffer.from(bits).toString('base64')}`;
}

async function verifyPassword(password, stored) {
  const [prefix, iterations, saltB64, hashB64] = stored.split('$');
  if (prefix !== 'pbkdf2_sha256') return false;
  const salt = new Uint8Array(Buffer.from(saltB64, 'base64'));
  const expected = Buffer.from(hashB64, 'base64');
  const key = await crypto.subtle.importKey('raw', utf8.encode(password), 'PBKDF2', false, ['deriveBits']);
  const bits = Buffer.from(
    await crypto.subtle.deriveBits(
      { name: 'PBKDF2', hash: 'SHA-256', salt, iterations: Number(iterations) },
      key,
      expected.length * 8,
    ),
  );
  return bits.equals(expected);
}

let passed = 0;
const check = (name, fn) => fn().then(() => { console.log(`  ok  ${name}`); passed++; });

const SECRET = 'smoke-test-secret-not-for-production-0123456789abcdef';

await check('JWT 签发格式为三段式', async () => {
  const token = await signJwt('u-123', SECRET, Date.now());
  assert.equal(token.split('.').length, 3);
});

await check('JWT 校验：正确 sub / typ / exp', async () => {
  const now = Date.now();
  const token = await signJwt('u-123', SECRET, now);
  const payload = await verifyJwt(token, SECRET);
  assert.equal(payload.sub, 'u-123');
  assert.equal(payload.typ, 'access');
  assert.equal(payload.exp, now + ACCESS_TOKEN_TTL_MS);
});

await check('JWT 校验：错误 secret 拒绝', async () => {
  const token = await signJwt('u-123', SECRET, Date.now());
  assert.equal(await verifyJwt(token, 'another-secret'), null);
});

await check('JWT 校验：篡改 payload 拒绝', async () => {
  const token = await signJwt('u-123', SECRET, Date.now());
  const parts = token.split('.');
  const forged = JSON.stringify({ sub: 'u-victim', iat: Date.now(), exp: Date.now() + 7200000, typ: 'access' });
  const tampered = `${parts[0]}.${Buffer.from(forged).toString('base64url')}.${parts[2]}`;
  assert.equal(await verifyJwt(tampered, SECRET), null);
});

await check('JWT 校验：过期拒绝', async () => {
  const token = await signJwt('u-123', SECRET, Date.now() - ACCESS_TOKEN_TTL_MS - 1000);
  assert.equal(await verifyJwt(token, SECRET), null);
});

await check('PBKDF2 哈希格式与校验通过', async () => {
  const hash = await hashPassword('p@ssw0rd123');
  const parts = hash.split('$');
  assert.equal(parts[0], 'pbkdf2_sha256');
  assert.equal(parts[1], '150000');
  assert.ok(await verifyPassword('p@ssw0rd123', hash));
});

await check('PBKDF2 校验：错误密码拒绝 / 盐随机', async () => {
  const hash = await hashPassword('p@ssw0rd123');
  assert.equal(await verifyPassword('wrong-pass', hash), false);
  const other = await hashPassword('p@ssw0rd123');
  assert.notEqual(hash, other); // 每次盐随机
});

console.log(`\nJWT/PBKDF2 冒烟通过：${passed} 项断言全部成功`);
