/// Domain-level AI failures. UI layers map these to user-facing messages.
sealed class AiFailure implements Exception {
  const AiFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

final class AiAuthFailure extends AiFailure {
  const AiAuthFailure([super.message = 'Key 无效或额度不足，请检查后重试']);
}

final class AiQuotaFailure extends AiFailure {
  const AiQuotaFailure([super.message = 'Key 无效或额度不足，请检查后重试']);
}

/// 上游限流/过载（智谱 1302/1305/1308/1310）：**可自动重试**。
///
/// 与 [AiQuotaFailure] 区分开的原因：欠费（1113）重试再久也没用，
/// 而过载（1305）等一分钟往往就恢复了，UI 需要不同处理。
final class AiRateLimitFailure extends AiFailure {
  const AiRateLimitFailure([super.message = '模型服务当前繁忙，请稍后重试']);
}

final class AiNetworkFailure extends AiFailure {
  const AiNetworkFailure([super.message = '网络异常，请检查网络后重试']);
}

final class AiTimeoutFailure extends AiFailure {
  const AiTimeoutFailure([super.message = '生成超时，请重试']);
}

final class AiParseFailure extends AiFailure {
  const AiParseFailure([super.message = '生成失败，请重试']);
}

/// Cancellation is a normal user action, not an [AiFailure].
class AiCancelledException implements Exception {
  const AiCancelledException();

  @override
  String toString() => '请求已取消';
}
