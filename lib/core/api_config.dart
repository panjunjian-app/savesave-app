/// 云同步 API 配置常量（架构 §6.1）。
///
/// baseUrl 指向 Cloudflare Pages 默认域；绑定自有域名时只需改这一处（Q5）。
/// JWT secret 等敏感信息不在客户端配置中，由服务端 `wrangler secret` 注入。
class ApiConfig {
  const ApiConfig._();

  /// 云端 API 基地址。部署后替换为 `<project>.pages.dev`；
  /// 本地联调用 `wrangler pages dev` 时改为 http://localhost:8788。
  static const String baseUrl = 'https://savesave.pages.dev';

  /// 常规请求超时。
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// 同步单批最大行数（架构 §9.8：≤500 行 / ≤2MB）。
  static const int syncBatchRows = 500;

  /// 同步请求体字节上限（与 Cloudflare Functions 端一致）。
  static const int syncPayloadBytes = 2 * 1024 * 1024;

  /// 增量拉取每页行数。
  static const int pullPageSize = 500;

  /// 本地写操作后的推送节流窗口（R1：批量合并 ≤5s）。
  static const Duration pushDebounce = Duration(seconds: 5);

  /// 前台定时增量同步间隔（R1：启动/恢复联网/定时触发）。
  static const Duration periodicSyncInterval = Duration(seconds: 60);

  /// 推送失败重试的指数退避序列（R7），超出后保持上限值。
  static const List<Duration> pushRetryBackoff = <Duration>[
    Duration(seconds: 15),
    Duration(minutes: 2),
    Duration(minutes: 10),
  ];

  /// 云端不可用时的降级探活路径（S10：自动降级为纯本地模式并提示）。
  static const String healthPath = '/api/health';
}
