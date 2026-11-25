/**
 * Cloudflare Pages Functions 共享环境类型（零 npm 依赖，手工最小声明）。
 *
 * 官方 `@cloudflare/workers-types` 属于 npm 依赖，本仓库约定后端零依赖，
 * 因此这里仅声明实际用到的能力子集。
 */

/** D1 预编译语句的最小能力面。 */
export interface D1PreparedStatement {
  bind(...values: unknown[]): D1PreparedStatement;
  first<T = Record<string, unknown>>(colName?: string): Promise<T | null>;
  all<T = Record<string, unknown>>(): Promise<D1Result<T>>;
  run(): Promise<D1Result<Record<string, unknown>>>;
}

export interface D1Result<T> {
  results: T[];
  success: boolean;
  meta?: Record<string, unknown>;
}

/** D1 数据库 binding 的最小能力面。 */
export interface D1Database {
  prepare(query: string): D1PreparedStatement;
  batch<T = Record<string, unknown>>(
    statements: D1PreparedStatement[],
  ): Promise<D1Result<T>[]>;
  exec(query: string): Promise<{ results?: unknown[] }>;
}

/** Pages Functions 环境绑定（wrangler.toml [d1_databases] + [vars] + secrets）。 */
export interface Env {
  /** D1 binding：云端权威副本。 */
  DB: D1Database;
  /** JWT HMAC-SHA256 签名密钥（wrangler pages secret put JWT_SECRET 注入）。 */
  JWT_SECRET: string;
  /** 跨域白名单（逗号分隔），同域请求无需 CORS。 */
  ALLOWED_ORIGINS?: string;
}

/** Pages Functions 请求上下文的最小能力面。 */
export interface FunctionContext {
  request: Request;
  env: Env;
  params: Record<string, string | string[]>;
  /** 中间件往下游传递的数据（如 JWT 校验后的 userId）。 */
  data: Record<string, unknown>;
  waitUntil(promise: Promise<unknown>): void;
}

/** Pages Functions 通用处理函数签名。 */
export type Handler = (
  request: Request,
  env: Env,
  ctx: FunctionContext,
) => Promise<Response> | Response;
