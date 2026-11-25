/**
 * 密码哈希：PBKDF2-SHA256（Web Crypto 原生，架构 §1.1）。
 *
 * 最终参数：**100,000** 次迭代（Cloudflare Workers 运行时的硬上限，
 * 超过会抛 `Pbkdf2 failed: iteration counts above 100000 are not supported`）、
 * 每用户 16 字节随机盐、输出 32 字节。
 * 存储格式：`pbkdf2_sha256$100000$<salt_b64>$<hash_b64>`（参数内联，
 * 未来换算法/加迭代无需改表结构）。
 */

const ITERATIONS = 100_000;
const SALT_BYTES = 16;
const HASH_BYTES = 32;
const FORMAT_PREFIX = 'pbkdf2_sha256';

/** 标准 base64（含填充），仅用于哈希存储格式。 */
function toBase64(bytes: Uint8Array): string {
  let binary = '';
  for (const byte of bytes) {
    binary += String.fromCharCode(byte);
  }
  return btoa(binary);
}

function fromBase64(text: string): Uint8Array {
  const binary = atob(text);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) {
    bytes[i] = binary.charCodeAt(i);
  }
  return bytes;
}

/** 生成密码哈希（注册时调用）。 */
export async function hashPassword(password: string): Promise<string> {
  const salt = crypto.getRandomValues(new Uint8Array(SALT_BYTES));
  const derived = await deriveBits(password, salt, ITERATIONS);
  return `${FORMAT_PREFIX}$${ITERATIONS}$${toBase64(salt)}$${toBase64(derived)}`;
}

/**
 * 校验密码（登录时调用）。读取存储格式中的参数重算后恒定时间比较；
 * 格式非法一律返回 false（等价于密码错误，不泄露内部状态）。
 */
export async function verifyPassword(password: string, stored: string): Promise<boolean> {
  const parts = stored.split('$');
  if (parts.length !== 4 || parts[0] !== FORMAT_PREFIX) {
    return false;
  }
  const iterations = Number.parseInt(parts[1], 10);
  if (!Number.isFinite(iterations) || iterations < 1 || iterations > 1_000_000) {
    return false;
  }
  let salt: Uint8Array;
  let expected: Uint8Array;
  try {
    salt = fromBase64(parts[2]);
    expected = fromBase64(parts[3]);
  } catch {
    return false;
  }
  const derived = await deriveBits(password, salt, iterations);
  if (derived.length !== expected.length) {
    return false;
  }
  let diff = 0;
  for (let i = 0; i < derived.length; i++) {
    diff |= derived[i] ^ expected[i];
  }
  return diff === 0;
}

/** PBKDF2-SHA256 派生。 */
async function deriveBits(
  password: string,
  salt: Uint8Array,
  iterations: number,
): Promise<Uint8Array> {
  const keyMaterial = await crypto.subtle.importKey(
    'raw',
    new TextEncoder().encode(password),
    'PBKDF2',
    false,
    ['deriveBits'],
  );
  const bits = await crypto.subtle.deriveBits(
    {
      name: 'PBKDF2',
      hash: 'SHA-256',
      salt: salt as unknown as ArrayBuffer,
      iterations,
    },
    keyMaterial,
    HASH_BYTES * 8,
  );
  return new Uint8Array(bits);
}
