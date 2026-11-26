import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:savesave/core/api_client.dart';
import 'package:savesave/core/layout_tokens.dart';
import 'package:savesave/core/theme.dart';
import 'package:savesave/data/database.dart';
import 'package:savesave/domain/services/auth_service.dart';
import 'package:savesave/domain/services/token_store.dart';
import 'package:savesave/features/auth/auth_page.dart';
import 'package:savesave/state/service_providers.dart';

/// P2-4 回归用例：登录页「暂不注册，以游客模式体验」文案不得被截断。
///
/// 缺陷现场（QA v4 回归报告 §5 P2-4）：1440 下按钮锁死 240px、文案 14px +
/// 图标，文本被 ellipsis 截成「暂不注册，以游客模式体...」。
///
/// 修复口径：
/// - 桌面档仍守 A4「单按钮 ≤ 240px」，靠 13px 字号把 12 个汉字排进 240；
/// - 手机档（compact）保持改造前的全宽观感，与 v1.2.0 一致。
///
/// 本文件用**真实登录页**做像素级断言（不复制粘贴一份假页面，避免「测试通过
/// 但线上仍截断」）。
const String _guestLabel = '暂不注册，以游客模式体验';

/// 内存版安全存储：避免测试环境触碰 Keychain / localStorage 插件。
class _MemoryStore implements SecureKeyValueStore {
  final Map<String, String> _values = <String, String>{};

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async => _values[key] = value;

  @override
  Future<void> delete(String key) async => _values.remove(key);

  @override
  Future<void> clear() async => _values.clear();
}

/// 空实现云端通道：本用例只渲染登录页，不发起任何网络请求。
class _NoopAuthRemote implements AuthRemote {
  @override
  Future<AuthSessionResponse> register({
    required String email,
    required String password,
    String? nickname,
  }) async {
    throw const ApiFailure('NOOP', '测试不发起注册');
  }

  @override
  Future<AuthSessionResponse> login({
    required String email,
    required String password,
  }) async {
    throw const ApiFailure('NOOP', '测试不发起登录');
  }

  @override
  Future<AuthSessionResponse?> restore() async => null;

  @override
  Future<void> logout() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late AuthService authService;

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    db = AppDatabase.forTesting(NativeDatabase.memory());
    authService = AuthService(
      db,
      remote: _NoopAuthRemote(),
      tokenStore: TokenStore(storage: _MemoryStore()),
    );
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> pumpAuthPageAt(WidgetTester tester, double width) async {
    tester.view.physicalSize = Size(width, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[authServiceProvider.overrideWithValue(authService)],
        child: MaterialApp(theme: AppTheme.light, home: const AuthPage()),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// 该文案所在 `RenderParagraph` 是否发生了省略号截断。
  bool didEllipsize(WidgetTester tester) {
    final RenderParagraph paragraph =
        tester.renderObject<RenderParagraph>(find.text(_guestLabel));
    return paragraph.didExceedMaxLines;
  }

  group('P2-4 登录页游客按钮', () {
    testWidgets('1440 桌面档：宽度 ≤240 且文案完整不截断', (tester) async {
      await pumpAuthPageAt(tester, 1440);

      expect(find.text(_guestLabel), findsOneWidget);
      final Size buttonSize = tester.getSize(
        find.ancestor(
          of: find.text(_guestLabel),
          matching: find.byType(OutlinedButton),
        ),
      );
      expect(buttonSize.width, lessThanOrEqualTo(AppLayout.buttonMaxWidth));
      expect(buttonSize.width, greaterThanOrEqualTo(AppLayout.buttonMinWidth));
      expect(
        didEllipsize(tester),
        isFalse,
        reason: '文案被 ellipsis 截断（P2-4 回归）',
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('768 medium 档：文案同样不截断', (tester) async {
      await pumpAuthPageAt(tester, 768);

      expect(
        didEllipsize(tester),
        isFalse,
        reason: 'medium 档复用同一表单卡，文案应完整',
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('390 手机档：按钮保持全宽（与改造前一致）', (tester) async {
      await pumpAuthPageAt(tester, 390);

      final Size buttonSize = tester.getSize(
        find.ancestor(
          of: find.text(_guestLabel),
          matching: find.byType(OutlinedButton),
        ),
      );
      // compact 分支：水平内距 32 × 2（v1.2.0 既有值），按钮撑满余宽。
      expect(buttonSize.width, 390 - 32 * 2);
      expect(
        didEllipsize(tester),
        isFalse,
        reason: '手机端按钮全宽，文案必须完整',
      );
      expect(tester.takeException(), isNull);
    });
  });
}
