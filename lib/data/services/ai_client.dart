import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:decimal/decimal.dart';

import '../../core/config.dart';
import '../../core/money.dart';
import '../../domain/services/key_store.dart';
import 'ai_failures.dart';

export 'ai_failures.dart';

/// Connection states of the three-state test-connection flow.
enum ConnectionResult { success, invalidKeyOrQuota, networkError }

/// Raw field-level bill extraction. Amounts are converted to cents immediately.
class BillDraftExtract {
  const BillDraftExtract({
    this.amountCents,
    this.type,
    this.category,
    this.date,
    this.note,
    this.ledger,
    this.confidence,
  });

  final int? amountCents;
  final String? type;
  final String? category;
  final String? date;
  final String? note;
  final String? ledger;
  final Map<String, double>? confidence;
}

class IncomeSummary {
  const IncomeSummary({
    required this.totalCents,
    this.mainCategoryKey = '',
    this.mainCategoryName = '',
  });

  final int totalCents;
  final String mainCategoryKey;
  final String mainCategoryName;
}

class CategorySummary {
  const CategorySummary({
    required this.categoryKey,
    required this.categoryName,
    required this.amountCents,
    required this.ratio,
    required this.count,
  });

  final String categoryKey;
  final String categoryName;
  final int amountCents;
  final Decimal ratio;
  final int count;
}

class ExpenseDetail {
  const ExpenseDetail({
    required this.itemKey,
    required this.categoryKey,
    required this.categoryName,
    required this.amountCents,
    required this.date,
    this.maskedNote,
  });

  final String itemKey;
  final String categoryKey;
  final String categoryName;
  final int amountCents;
  final String date;
  final String? maskedNote;
}

class GoalContext {
  const GoalContext({
    required this.hasGoal,
    this.goalKey,
    this.targetCents,
    this.balanceCents,
    this.remainingCents,
    this.remainingMonths,
    this.monthlyGapCents,
    required this.strategy,
  });

  final bool hasGoal;
  final String? goalKey;
  final int? targetCents;
  final int? balanceCents;
  final int? remainingCents;
  final int? remainingMonths;
  final int? monthlyGapCents;
  final String strategy;
}

/// Fully local, de-identified and truncated payload sent to the AI provider.
class AnalysisPayload {
  const AnalysisPayload({
    required this.periodType,
    required this.periodLabel,
    required this.categories,
    required this.income,
    required this.expenseTotalCents,
    required this.savingRate,
    required this.topExpenses,
    required this.goal,
    this.includeNotes = false,
    this.ledgerAlias = const <String, String>{},
  });

  final String periodType;
  final String periodLabel;
  final List<CategorySummary> categories;
  final IncomeSummary income;
  final int expenseTotalCents;
  final Decimal savingRate;
  final List<ExpenseDetail> topExpenses;
  final GoalContext goal;
  final bool includeNotes;
  final Map<String, String> ledgerAlias;

  bool get isEmpty => categories.isEmpty && topExpenses.isEmpty;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'periodType': periodType,
        'periodLabel': periodLabel,
        'categories': categories
            .map(
              (item) => <String, dynamic>{
                'categoryKey': item.categoryKey,
                'categoryName': item.categoryName,
                'amountCents': item.amountCents,
                'ratio': item.ratio.toString(),
                'count': item.count,
              },
            )
            .toList(growable: false),
        'income': <String, dynamic>{
          'totalCents': income.totalCents,
          'mainCategoryKey': income.mainCategoryKey,
          'mainCategoryName': income.mainCategoryName,
        },
        'expenseTotalCents': expenseTotalCents,
        'savingRate': savingRate.toString(),
        'topExpenses': topExpenses
            .map(
              (item) => <String, dynamic>{
                'itemKey': item.itemKey,
                'categoryKey': item.categoryKey,
                'categoryName': item.categoryName,
                'amountCents': item.amountCents,
                'date': item.date,
                if (includeNotes && item.maskedNote != null)
                  'maskedNote': item.maskedNote,
              },
            )
            .toList(growable: false),
        'goal': <String, dynamic>{
          'hasGoal': goal.hasGoal,
          'goalKey': goal.goalKey,
          'targetCents': goal.targetCents,
          'balanceCents': goal.balanceCents,
          'remainingCents': goal.remainingCents,
          'remainingMonths': goal.remainingMonths,
          'monthlyGapCents': goal.monthlyGapCents,
          'strategy': goal.strategy,
        },
        'ledgerAlias': ledgerAlias,
      };
}

class OptimizeAdvice {
  const OptimizeAdvice({required this.categoryKey, required this.advice});

  final String categoryKey;
  final String advice;
}

class UnnecessaryItem {
  const UnnecessaryItem({
    required this.itemKey,
    required this.reason,
    required this.action,
  });

  final String itemKey;
  final String reason;
  final String action;
}

/// Raw AI text output. Numbers are prohibited; placeholders are used instead.
class AiAnalysisText {
  const AiAnalysisText({
    required this.overviewComment,
    required this.optimizeAdvices,
    required this.unnecessaryItems,
    required this.goalComment,
    this.noGoalSuggestion,
    required this.actionItems,
  });

  final String overviewComment;
  final List<OptimizeAdvice> optimizeAdvices;
  final List<UnnecessaryItem> unnecessaryItems;
  final String goalComment;
  final String? noGoalSuggestion;
  final List<String> actionItems;
}

/// Pluggable authentication. Bearer is the default; JWT is a 401 fallback.
abstract interface class AuthStrategy {
  const AuthStrategy();

  void apply(RequestOptions request, String key);
}

final class BearerAuth implements AuthStrategy {
  const BearerAuth();

  @override
  void apply(RequestOptions request, String key) {
    request.headers['Authorization'] = 'Bearer $key';
  }
}

final class JwtAuth implements AuthStrategy {
  const JwtAuth();

  static const int _ttlSeconds = 3600;

  @override
  void apply(RequestOptions request, String key) {
    final separator = key.indexOf('.');
    if (separator <= 0 || separator == key.length - 1) {
      throw const AiAuthFailure('API Key 格式不支持 JWT 鉴权');
    }
    final issuer = key.substring(0, separator);
    final secret = key.substring(separator + 1);
    final now = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    final header = _base64Url(jsonEncode(<String, dynamic>{
      'alg': 'HS256',
      'typ': 'JWT',
    }));
    final payload = _base64Url(jsonEncode(<String, dynamic>{
      'iss': issuer,
      'exp': now + _ttlSeconds,
      'iat': now,
    }));
    final signingInput = '$header.$payload';
    final signature = _base64Url(
      Hmac(sha256, utf8.encode(secret)).convert(utf8.encode(signingInput)).bytes,
    );
    request.headers['Authorization'] = '$signingInput.$signature';
  }

  static String _base64Url(Object input) {
    final bytes = input is String ? utf8.encode(input) : input as List<int>;
    return base64Url.encode(bytes).replaceAll('=', '');
  }
}

/// Dio interceptor that keeps diagnostics redacted. It never changes the real
/// Authorization header or request body, and no LogInterceptor is attached.
class AiRedactingInterceptor extends Interceptor {
  const AiRedactingInterceptor();

  static const Set<String> _sensitiveKeys = <String>{
    'authorization',
    'api-key',
    'api_key',
  };

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra['ai_redacted_headers'] = _redact(options.headers);
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    response.extra['ai_redacted_headers'] = _redact(response.requestOptions.headers);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    err.requestOptions.extra['ai_redacted_headers'] =
        _redact(err.requestOptions.headers);
    handler.next(err);
  }

  Map<String, dynamic> _redact(Map<String, dynamic> headers) {
    return <String, dynamic>{
      for (final entry in headers.entries)
        entry.key: _sensitiveKeys.contains(entry.key.toLowerCase())
            ? '<redacted>'
            : entry.value,
    };
  }
}

/// BYOK AI client with a single Dio instance, 15s timeout and five failures.
class AiClient {
  AiClient({
    AiKeyStore? keyStore,
    Dio? dio,
    AuthStrategy? auth,
  })  : _keyStore = keyStore ?? AiKeyStore(),
        _auth = auth ?? const BearerAuth(),
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: AiConfig.endpoint,
                connectTimeout: AiConfig.timeout,
                sendTimeout: AiConfig.timeout,
                receiveTimeout: AiConfig.timeout,
                headers: <String, dynamic>{'Content-Type': 'application/json'},
              ),
            ) {
    _dio.interceptors.add(const AiRedactingInterceptor());
  }

  final AiKeyStore _keyStore;
  final Dio _dio;
  final AuthStrategy _auth;

  /// Smallest possible text request: no image, 8 output tokens.
  Future<ConnectionResult> testConnection() async {
    try {
      await _chat(
        body: <String, dynamic>{
          'model': AiConfig.modelId,
          'messages': <Map<String, dynamic>>[
            <String, dynamic>{'role': 'user', 'content': '只回复：ok'},
          ],
          'max_tokens': AiConfig.maxTokensForConnectionTest,
          'temperature': 0,
        },
        token: CancelToken(),
      );
      return ConnectionResult.success;
    } on AiAuthFailure {
      return ConnectionResult.invalidKeyOrQuota;
    } on AiQuotaFailure {
      return ConnectionResult.invalidKeyOrQuota;
    } on AiFailure {
      return ConnectionResult.networkError;
    }
  }

  /// Image recognition for one bill. The caller must review before saving.
  Future<BillDraftExtract> recognizeBill({
    required Uint8List bytes,
    required CancelToken token,
  }) async {
    final dataUri = 'data:image/jpeg;base64,${base64.encode(bytes)}';
    final response = await _chat(
      body: <String, dynamic>{
        'model': AiConfig.modelId,
        'messages': <Map<String, dynamic>>[
          <String, dynamic>{
            'role': 'user',
            'content': <Map<String, dynamic>>[
              <String, dynamic>{
                'type': 'text',
                'text': AiConfig.billRecognitionPrompt,
              },
              <String, dynamic>{
                'type': 'image_url',
                'image_url': <String, dynamic>{'url': dataUri},
              },
            ],
          },
        ],
        'response_format': <String, dynamic>{'type': 'json_object'},
        'max_tokens': AiConfig.maxTokensForBillRecognition,
        'temperature': 0,
      },
      token: token,
    );

    final json = _parseJsonObject(_extractContent(response));
    return BillDraftExtract(
      amountCents: _parseAmount(json['amount']),
      type: _asNullableString(json['type']),
      category: _asNullableString(json['category']),
      date: _asNullableString(json['date']),
      note: _asNullableString(json['note']),
      ledger: _asNullableString(json['ledger']),
      confidence: _parseConfidence(json['confidence']),
    );
  }

  /// C4 analysis. Payload is already de-identified and truncated by the builder.
  Future<AiAnalysisText> analyzeFinances({
    required AnalysisPayload payload,
    required CancelToken token,
  }) async {
    if (payload.isEmpty) {
      throw ArgumentError.value(payload, 'payload', '空数据不得发起分析请求');
    }
    final response = await _chat(
      body: <String, dynamic>{
        'model': AiConfig.modelId,
        'messages': <Map<String, dynamic>>[
          <String, dynamic>{
            'role': 'system',
            'content': AnalysisPrompt.system,
          },
          <String, dynamic>{
            'role': 'user',
            'content': jsonEncode(payload.toJson()),
          },
        ],
        'response_format': <String, dynamic>{'type': 'json_object'},
        'max_tokens': AiConfig.maxTokensForAnalysis,
        'temperature': 0.2,
        'do_sample': false,
        'thinking': <String, dynamic>{'type': 'disabled'},
      },
      token: token,
    );
    return _parseAnalysisText(_extractContent(response));
  }

  Future<Map<String, dynamic>> _chat({
    required Map<String, dynamic> body,
    required CancelToken token,
  }) async {
    final key = await _keyStore.readKey();
    if (key == null || key.isEmpty) {
      throw const AiAuthFailure('尚未配置 API Key');
    }

    try {
      return await _send(body: body, key: key, token: token, auth: _auth);
    } on AiAuthFailure {
      // V1 verification pending: retry at most once with the JWT strategy.
      if (_auth is JwtAuth) {
        rethrow;
      }
      return _send(
        body: body,
        key: key,
        token: token,
        auth: const JwtAuth(),
      );
    }
  }

  Future<Map<String, dynamic>> _send({
    required Map<String, dynamic> body,
    required String key,
    required CancelToken token,
    required AuthStrategy auth,
  }) async {
    final request = RequestOptions(
      path: AiConfig.chatCompletionsPath,
      method: 'POST',
      headers: <String, dynamic>{},
    );
    auth.apply(request, key);

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        AiConfig.chatCompletionsPath,
        data: body,
        cancelToken: token,
        options: Options(headers: request.headers),
      );
      final Object? data = response.data;
      if (data is Map<String, dynamic>) {
        return data;
      }
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      throw const AiParseFailure();
    } on DioException catch (error) {
      return _mapDioException(error);
    }
  }

  Never _mapDioException(DioException error) {
    if (error.type == DioExceptionType.cancel) {
      throw const AiCancelledException();
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      throw const AiTimeoutFailure();
    }
    final status = error.response?.statusCode;
    if (status == 401 || status == 403) {
      throw const AiAuthFailure();
    }
    if (status == 429) {
      throw const AiQuotaFailure();
    }
    if (status != null && status >= 500) {
      throw const AiNetworkFailure();
    }

    final data = error.response?.data;
    final text = (data is Map ? jsonEncode(data) : data?.toString() ?? '').toLowerCase();
    const quotaHints = <String>['quota', 'insufficient balance', '余额', '额度'];
    const authHints = <String>['invalid key', 'unauthorized', 'invalid api key'];
    if (quotaHints.any(text.contains)) {
      throw const AiQuotaFailure();
    }
    if (authHints.any(text.contains)) {
      throw const AiAuthFailure();
    }
    throw const AiNetworkFailure();
  }

  String _extractContent(Map<String, dynamic> response) {
    final choices = response['choices'];
    if (choices is! List || choices.isEmpty) {
      throw const AiParseFailure();
    }
    final first = choices.first;
    if (first is! Map) {
      throw const AiParseFailure();
    }
    final message = first['message'];
    if (message is! Map) {
      throw const AiParseFailure();
    }
    final content = message['content'];
    if (content is! String || content.trim().isEmpty) {
      throw const AiParseFailure();
    }
    return content;
  }

  Map<String, dynamic> _parseJsonObject(String content) {
    var text = content.trim();
    text = text
        .replaceFirst(RegExp(r'^```(?:json)?', caseSensitive: false), '')
        .replaceFirst(RegExp(r'```$'), '')
        .trim();

    Object? decoded;
    try {
      decoded = jsonDecode(text);
    } on FormatException {
      final start = text.indexOf('{');
      final end = text.lastIndexOf('}');
      if (start < 0 || end <= start) {
        throw const AiParseFailure();
      }
      try {
        decoded = jsonDecode(text.substring(start, end + 1));
      } on FormatException {
        throw const AiParseFailure();
      }
    }
    if (decoded is! Map<String, dynamic>) {
      throw const AiParseFailure();
    }
    return decoded;
  }

  int? _parseAmount(Object? value) {
    if (value == null) {
      return null;
    }
    try {
      if (value is num) {
        return Money.parseYuanToCents(value.toString());
      }
      return Money.parseYuanToCents(value.toString());
    } on FormatException {
      return null;
    } on ArgumentError {
      return null;
    }
  }

  Map<String, double>? _parseConfidence(Object? value) {
    if (value is! Map) {
      return null;
    }
    return <String, double>{
      for (final entry in value.entries)
        entry.key.toString(): (entry.value as num?)?.toDouble() ?? 0.0,
    };
  }

  String? _asNullableString(Object? value) {
    if (value == null) {
      return null;
    }
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  AiAnalysisText _parseAnalysisText(String content) {
    final json = _parseJsonObject(content);
    return AiAnalysisText(
      overviewComment: _asNullableString(json['overviewComment']) ?? '',
      optimizeAdvices: (json['optimizeAdvices'] as List<dynamic>? ?? [])
          .whereType<Map>()
          .map(
            (item) => OptimizeAdvice(
              categoryKey: _asNullableString(item['categoryKey']) ?? '',
              advice: _asNullableString(item['advice']) ?? '',
            ),
          )
          .toList(growable: false),
      unnecessaryItems: (json['unnecessaryItems'] as List<dynamic>? ?? [])
          .whereType<Map>()
          .map(
            (item) => UnnecessaryItem(
              itemKey: _asNullableString(item['itemKey']) ?? '',
              reason: _asNullableString(item['reason']) ?? '其他',
              action: _asNullableString(item['action']) ?? '',
            ),
          )
          .toList(growable: false),
      goalComment: _asNullableString(json['goalComment']) ?? '',
      noGoalSuggestion: _asNullableString(json['noGoalSuggestion']),
      actionItems: (json['actionItems'] as List<dynamic>? ?? [])
          .map((item) => _asNullableString(item) ?? '')
          .where((item) => item.isNotEmpty)
          .toList(growable: false),
    );
  }
}

/// System prompt for AI financial commentary (T19 validator consumes the output).
abstract final class AnalysisPrompt {
  static const String system = '''
你是理财点评助手，只输出 JSON，不要 Markdown 代码围栏。
铁律：不得输出任何字面数字、金额、百分比、日期或货币符号；需要引用数值时只能使用白名单占位符原文：
{{income}} {{expense}} {{balance}} {{savingRate}} {{categoryAmount}} {{categoryRatio}}
{{categoryCount}} {{detailAmount}} {{goalTarget}} {{goalBalance}} {{goalRemaining}}
{{remainingMonths}} {{monthlyGap}} {{monthlyAvgNet}} {{deadline}}
optimizeAdvices.categoryKey 必须来自输入 categories[].categoryKey；
unnecessaryItems.itemKey 必须来自输入 topExpenses[].itemKey；不得杜撰名称。
不输出备注原文、商户全名、姓名、手机号、卡号、地址或精确时间点。
输出 JSON 形状：
{
  "overviewComment": "≤160字",
  "optimizeAdvices": [{"categoryKey": "...", "advice": "≤120字"}],
  "unnecessaryItems": [{"itemKey": "...", "reason": "订阅续费|冲动消费|低频高额|重复支出|其他", "action": "≤80字"}],
  "goalComment": "≤200字",
  "noGoalSuggestion": "≤120字",
  "actionItems": ["3-5条，每条≤40字"]
}
无内容返回空数组或空字符串。goal.strategy=buildPositive 时不做达标承诺；
goal.strategy=generic 时 goalComment 返回空字符串并改写 noGoalSuggestion。
''';
}
