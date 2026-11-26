import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:savesave/features/common/responsive_scaffold.dart';
import 'package:savesave/features/ledger/ledger_form_page.dart';

/// v1.4.0 · 手机端二级页返回通路回归测试。
///
/// 缺陷背景（用户反馈）：全站路由统一 `context.go`，页面栈里没有上一页，
/// `Navigator.canPop` 恒为 false —— 手机端 `_compactScaffold` 既不画返回箭头，
/// 也没接管系统返回键，导致「新建账本」等 11 个二级页进去就出不来。
///
/// 本文件锁死三件事：
/// 1. compact 档 `backLocation` 非空 → 有返回箭头，点击回目标路径；
/// 2. compact 档系统返回键不会退出 App，而是 `go(backLocation)`；
/// 3. 没传 `backLocation` 的一级页不凭空多出箭头（像素不回退）。
GoRouter _router({String initial = '/second'}) {
  return GoRouter(
    initialLocation: initial,
    routes: <RouteBase>[
      GoRoute(path: '/first', builder: _first),
      GoRoute(path: '/second', builder: _second),
      GoRoute(path: '/plain', builder: _plain),
      GoRoute(path: '/ledgers', builder: _first),
      GoRoute(path: '/ledgers/create', builder: _ledgerForm),
    ],
  );
}

Widget _first(BuildContext context, GoRouterState state) =>
    const Scaffold(body: Center(child: Text('FIRST')));

Widget _plain(BuildContext context, GoRouterState state) => const ResponsiveScaffold(
      title: '一级页',
      body: SizedBox.shrink(),
    );

Widget _second(BuildContext context, GoRouterState state) => const ResponsiveScaffold(
      title: '二级页',
      backLocation: '/first',
      body: SizedBox.shrink(),
    );

Widget _ledgerForm(BuildContext context, GoRouterState state) =>
    const LedgerFormPage();

Future<GoRouter> _pump(
  WidgetTester tester, {
  double width = 390,
  String initial = '/second',
}) async {
  tester.view.physicalSize = Size(width, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  final router = _router(initial: initial);
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

void main() {
  group('手机端返回通路', () {
    testWidgets('compact + backLocation：渲染返回箭头，点击回到目标页', (tester) async {
      await _pump(tester);

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('FIRST'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('compact 系统返回键：走 backLocation 而非退出 App', (tester) async {
      await _pump(tester);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.text('FIRST'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('compact 一级页（无 backLocation）：不凭空出现返回箭头', (tester) async {
      await _pump(tester, initial: '/plain');

      expect(find.byIcon(Icons.arrow_back), findsNothing);
      expect(find.text('一级页'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('桌面档保留原有返回箭头（无回归）', (tester) async {
      await _pump(tester, width: 1440);

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('新建账本页可退出', () {
    testWidgets('手机端有返回箭头 + 取消按钮，取消回到账本列表', (tester) async {
      await _pump(tester, initial: '/ledgers/create');

      expect(find.text('新建账本'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.text('取消'), findsOneWidget);

      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();

      expect(find.text('FIRST'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('手机端返回箭头同样回到账本列表', (tester) async {
      await _pump(tester, initial: '/ledgers/create');

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('FIRST'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
