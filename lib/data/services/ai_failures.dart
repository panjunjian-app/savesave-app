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
