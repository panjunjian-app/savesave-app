import 'package:dio/dio.dart';

import 'api_config.dart';
import '../domain/services/token_store.dart';

/// 云端会话信息（登录/注册/刷新接口的统一返回）。
class AuthSessionResponse {
  const AuthSessionResponse({
    required this.userId,
    required this.email,
    required this.nickname,
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthSessionResponse.fromJson(Map<String, dynamic> json) {
    final user = (json['user'] as Map<String, dynamic>?) ?? const <String, dynamic>{};
    return AuthSessionResponse(
      userId: user['id'] as String? ?? '',
      email: user['email'] as String? ?? '',
      nickname: user['nickname'] as String? ?? '',
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
    );
  }

  final String userId;
  final String email;
  final String nickname;
  final String accessToken;
  final String refreshToken;

  CloudSession toSession() => CloudSession(
        userId: userId,
        email: email,
        nickname: nickname,
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
}

/// 增量拉取响应（架构 §4.6）。
class PullResponse {
  const PullResponse({
    required this.serverTime,
    required this.hasMore,
    required this.changes,
  });

  final int serverTime;
  final bool hasMore;
  final Map<String, List<Map<String, dynamic>>> changes;
}

/// 推送响应（架构 §4.7）。
class PushResponse {
  const PushResponse({
    required this.serverTime,
    required this.accepted,
    required this.conflicts,
    required this.rejected,
  });

  final int serverTime;
  final List<String> accepted;
  final List<String> conflicts;
  final List<String> rejected;
}

/// 云端业务失败（错误码 → 中文文案映射见 [_messageForCode]）。
class ApiFailure implements Exception {
  const ApiFailure(this.code, this.message, {this.httpStatus});

  final String code;
  final String message;
  final int? httpStatus;

  @override
  String toString() => message;
}

/// 会话彻底失效（refresh 也失败）：客户端清 token 踢回登录页（§5.3）。
class SessionExpiredException implements Exception {
  const SessionExpiredException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// 网络不可用 / 云端不可达：调用方降级为本地模式（S10）。
class NetworkUnavailableException implements Exception {
  const NetworkUnavailableException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// 错误码 → 中文文案（架构 §4.8）。
String messageForCode(String code, String fallback) {
  switch (code) {
    case 'VALIDATION_ERROR':
      return '输入内容不合法，请检查后重试';
    case 'INVALID_CREDENTIALS':
      return '邮箱或密码不正确';
    case 'TOKEN_EXPIRED':
      return '登录已过期，正在重新登录';
    case 'REFRESH_INVALID':
      return '登录已失效，请重新登录';
    case 'FORBIDDEN':
      return '没有权限执行该操作';
    case 'NOT_FOUND':
      return '接口不存在';
    case 'EMAIL_EXISTS':
      return '该邮箱已注册，请直接登录';
    case 'PAYLOAD_TOO_LARGE':
      return '同步数据过大，请稍后重试';
    case 'RATE_LIMITED':
      return '操作过于频繁，请稍后再试';
    case 'INTERNAL':
      return '云端服务异常，请稍后重试';
    default:
      return fallback;
  }
}

/// 同步通道抽象（SyncService 依赖此接口，测试可 mock）。
abstract class SyncApi {
  Future<PullResponse> pull({required int since, int limit});
  Future<PushResponse> push(Map<String, List<Map<String, dynamic>>> changes);
}

/// 认证通道抽象（AuthService 依赖此接口，测试可 mock）。
abstract class AuthRemote {
  Future<AuthSessionResponse> register({
    required String email,
    required String password,
    String? nickname,
  });

  Future<AuthSessionResponse> login({required String email, required String password});

  /// 静默恢复会话；无 refreshToken 或失效时返回 null。
  Future<AuthSessionResponse?> restore();

  Future<void> logout();
}

/// dio 单例封装：JWT 头注入、401 单飞刷新重放、错误码映射（架构 §6.1）。
class ApiClient implements SyncApi, AuthRemote {
  ApiClient({
    required this.tokenStore,
    Dio? dio,
    String? baseUrl,
  })  : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: baseUrl ?? ApiConfig.baseUrl,
              connectTimeout: ApiConfig.connectTimeout,
              receiveTimeout: ApiConfig.receiveTimeout,
              headers: <String, String>{'Content-Type': 'application/json'},
            )) {
    // 每次请求动态注入 accessToken（token 可能被刷新轮换）。
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await tokenStore.readAccessToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
  }

  /// 会话令牌存储（构造注入，测试可用内存实现）。
  final TokenStore tokenStore;

  final Dio _dio;

  /// 单飞锁：并发 401 共享同一次 refresh（§5.3）。
  Future<bool>? _refreshing;

  // ============ 认证接口（AuthRemote） ============

  @override
  Future<AuthSessionResponse> register({
    required String email,
    required String password,
    String? nickname,
  }) async {
    final data = await _post('/api/auth/register', <String, dynamic>{
      'email': email,
      'password': password,
      if (nickname != null && nickname.isNotEmpty) 'nickname': nickname,
    }, authenticated: false);
    return AuthSessionResponse.fromJson(data);
  }

  @override
  Future<AuthSessionResponse> login({required String email, required String password}) async {
    final data = await _post('/api/auth/login', <String, dynamic>{
      'email': email,
      'password': password,
    }, authenticated: false);
    return AuthSessionResponse.fromJson(data);
  }

  @override
  Future<AuthSessionResponse?> restore() async {
    final refreshToken = await tokenStore.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return null;
    }
    try {
      return await _refreshTokens(refreshToken);
    } on SessionExpiredException {
      // refresh 失效：清 token，等价未登录（调用方回退本地/游客模式）。
      return null;
    }
  }

  @override
  Future<void> logout() async {
    final refreshToken = await tokenStore.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return;
    }
    try {
      await _dio.post<Map<String, dynamic>>(
        '/api/auth/logout',
        data: <String, dynamic>{'refreshToken': refreshToken},
      );
    } catch (_) {
      // 登出尽力而为：网络失败也不阻塞本地清理。
    }
  }

  // ============ 同步接口（SyncApi） ============

  @override
  Future<PullResponse> pull({required int since, int limit = ApiConfig.pullPageSize}) async {
    final data = await _post('/api/sync/pull', <String, dynamic>{
      'since': since,
      'limit': limit,
    });
    final rawChanges = (data['changes'] as Map<String, dynamic>?) ?? const <String, dynamic>{};
    final changes = <String, List<Map<String, dynamic>>>{};
    for (final entry in rawChanges.entries) {
      final rows = entry.value as List<dynamic>? ?? const <dynamic>[];
      changes[entry.key] = rows
          .whereType<Map<String, dynamic>>()
          .toList(growable: false);
    }
    return PullResponse(
      serverTime: (data['serverTime'] as num?)?.toInt() ?? 0,
      hasMore: data['hasMore'] == true,
      changes: changes,
    );
  }

  @override
  Future<PushResponse> push(Map<String, List<Map<String, dynamic>>> changes) async {
    final data = await _post('/api/sync/push', <String, dynamic>{'changes': changes});
    return PushResponse(
      serverTime: (data['serverTime'] as num?)?.toInt() ?? 0,
      accepted: ((data['accepted'] as List<dynamic>?) ?? const <dynamic>[])
          .whereType<String>()
          .toList(growable: false),
      conflicts: ((data['conflicts'] as List<dynamic>?) ?? const <dynamic>[])
          .whereType<String>()
          .toList(growable: false),
      rejected: ((data['rejected'] as List<dynamic>?) ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map((row) => row['id']?.toString() ?? '')
          .toList(growable: false),
    );
  }

  // ============ 内部：统一请求 / 刷新 / 错误映射 ============

  /// 统一 POST：解 {code,data} 包裹；401 TOKEN_EXPIRED 时单飞刷新并重放一次。
  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body, {
    bool authenticated = true,
  }) async {
    Response<Map<String, dynamic>> response;
    try {
      response = await _dio.post<Map<String, dynamic>>(path, data: body);
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      if (status == 401 && authenticated) {
        final refreshed = await _refreshSingleFlight();
        if (!refreshed) {
          throw const SessionExpiredException('登录已失效，请重新登录');
        }
        try {
          response = await _dio.post<Map<String, dynamic>>(path, data: body);
        } on DioException catch (retryError) {
          throw _toFailure(retryError, path);
        }
      } else {
        throw _toFailure(error, path);
      }
    } catch (_) {
      throw const NetworkUnavailableException('网络不可用，已切换为本地模式');
    }
    return _unwrap(response.data, path);
  }

  Map<String, dynamic> _unwrap(Map<String, dynamic>? body, String path) {
    if (body == null) {
      throw const NetworkUnavailableException('云端返回为空');
    }
    final code = body['code'];
    if (code is int && code == 0) {
      final data = body['data'];
      return data is Map<String, dynamic> ? data : <String, dynamic>{};
    }
    final errorCode = code?.toString() ?? 'INTERNAL';
    throw ApiFailure(
      errorCode,
      messageForCode(errorCode, body['message']?.toString() ?? '请求失败'),
    );
  }

  ApiFailure _toFailure(DioException error, String path) {
    final response = error.response;
    final status = response?.statusCode;
    if (status == null) {
      return const ApiFailure('NETWORK', '网络不可用，请检查连接后重试');
    }
    final body = response?.data;
    String code = 'INTERNAL';
    String message = '请求失败（HTTP $status）';
    if (body is Map<String, dynamic>) {
      code = body['code']?.toString() ?? code;
      message = body['message']?.toString() ?? message;
    }
    return ApiFailure(code, messageForCode(code, message), httpStatus: status);
  }

  /// 用 refreshToken 换新 token 对并持久化；失效抛 [SessionExpiredException]。
  Future<AuthSessionResponse> _refreshTokens(String refreshToken) async {
    Response<Map<String, dynamic>> response;
    try {
      response = await _dio.post<Map<String, dynamic>>(
        '/api/auth/refresh',
        data: <String, dynamic>{'refreshToken': refreshToken},
      );
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      if (status == 401) {
        throw const SessionExpiredException('登录已失效，请重新登录');
      }
      throw const NetworkUnavailableException('网络不可用，已切换为本地模式');
    }
    final session = AuthSessionResponse.fromJson(_unwrap(response.data, '/api/auth/refresh'));
    await tokenStore.saveSession(session.toSession());
    return session;
  }

  /// 单飞刷新：并发调用共享同一次请求，成功返回 true。
  Future<bool> _refreshSingleFlight() {
    return _refreshing ??= _doRefresh().whenComplete(() => _refreshing = null);
  }

  Future<bool> _doRefresh() async {
    final refreshToken = await tokenStore.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }
    try {
      await _refreshTokens(refreshToken);
      return true;
    } on SessionExpiredException {
      await tokenStore.clearSession();
      return false;
    } on NetworkUnavailableException {
      // 网络不通时不吊销会话：保留 token，待网络恢复后重试。
      return false;
    } on ApiFailure {
      await tokenStore.clearSession();
      return false;
    }
  }
}
