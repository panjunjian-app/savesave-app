import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savesave/core/layout_tokens.dart';
import 'package:savesave/features/common/adaptive_grid.dart';
import 'package:savesave/features/common/app_buttons.dart';
import 'package:savesave/features/common/app_shell.dart';
import 'package:savesave/features/common/responsive_scaffold.dart';
import 'package:savesave/features/common/side_nav.dart';

/// v4 响应式布局 · QA 补充审计用例（严过关）。
///
/// 与 `responsive_shell_test.dart` 互补，聚焦 PRD 硬约束的**边界口径**：
/// - B1 断点切换（599→600、1023→1024）三形态互斥、宽度精确；
/// - A2 内容区上限 1200 且水平居中（1920 视口实测留白均分）；
/// - A4 单按钮 ≤240，compact 例外全宽；
/// - §4.3 卡片网格列数映射。
Widget _wrap(Widget child) => ProviderScope(child: MaterialApp(home: child));

/// 只依赖共享件的探针页，避免触达 Drift / Provider。
class _Probe extends StatelessWidget {
  const _Probe();

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: '审计探针',
      primaryAction: AppButton.primary(label: '新建', onPressed: _noop),
      onRefresh: _refresh,
      // 手机端应保留 FAB，桌面档必须丢弃（P0-5）。
      floatingActionButton: const FloatingActionButton(
        onPressed: _noop,
        child: Icon(Icons.add),
      ),
      body: ListView(
        padding: context.pagePadding,
        children: const <Widget>[SizedBox(height: 200)],
      ),
    );
  }
}

void _noop() {}

Future<void> _refresh() async {}

void main() {
  group('B1 断点三形态边界', () {
    Future<void> pumpAt(WidgetTester tester, double width) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        _wrap(const AppShell(location: '/home', child: _Probe())),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('599 为 compact：底部 Tab、无侧栏、FAB 保留', (tester) async {
      await pumpAt(tester, 599);
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(AppSideNav), findsNothing);
      expect(find.byType(AppNavigationRail), findsNothing);
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('600 为 medium：76px 图标栏、无底部 Tab', (tester) async {
      await pumpAt(tester, 600);
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.byType(AppSideNav), findsNothing);
      expect(
        tester.getSize(find.byType(AppNavigationRail)).width,
        AppLayout.railWidth,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('1023 仍为 medium：不提前出完整侧栏', (tester) async {
      await pumpAt(tester, 1023);
      expect(find.byType(AppNavigationRail), findsOneWidget);
      expect(find.byType(AppSideNav), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('1024 为 expanded：240px 完整侧栏、FAB 消失', (tester) async {
      await pumpAt(tester, 1024);
      expect(find.byType(AppSideNav), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      expect(
        tester.getSize(find.byType(AppSideNav)).width,
        AppLayout.sideNavWidth,
      );
      expect(find.byType(FloatingActionButton), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('A2 内容区上限与居中', () {
    testWidgets('1920 视口：内容宽 ≤1200 且左右留白均分（±1px）', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _wrap(const AppShell(location: '/home', child: _Probe())),
      );
      await tester.pumpAndSettle();

      final double bodyWidth = tester.getSize(find.byType(ListView)).width;
      expect(bodyWidth, lessThanOrEqualTo(AppLayout.contentMaxWidth));

      // 内容区可用宽 = 1920 − 240 侧栏 − 1 分隔线 = 1679
      final double contentLeft = tester.getTopLeft(find.byType(ListView)).dx;
      final double leftGap = contentLeft - (AppLayout.sideNavWidth + 1);
      final double rightGap = 1920 - (contentLeft + bodyWidth);
      expect((leftGap - rightGap).abs(), lessThanOrEqualTo(1.0));
      expect(tester.takeException(), isNull);
    });

    testWidgets('1440 视口：可用宽 1199 未触发上限，内容不被压缩', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _wrap(const AppShell(location: '/home', child: _Probe())),
      );
      await tester.pumpAndSettle();

      expect(tester.getSize(find.byType(ListView)).width, 1440 - 240 - 1);
      expect(tester.takeException(), isNull);
    });
  });

  group('A4 按钮宽度', () {
    testWidgets('桌面档长文案按钮仍 ≤240', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _wrap(
          Scaffold(
            body: Center(
              child: AppButton.primary(
                label: '测试连接并校验账户余额可用性',
                onPressed: _noop,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final Size size = tester.getSize(find.byType(FilledButton));
      expect(size.width, lessThanOrEqualTo(AppLayout.buttonMaxWidth));
      expect(size.width, greaterThanOrEqualTo(AppLayout.buttonMinWidth));
      expect(tester.takeException(), isNull);
    });

    testWidgets('compact 档保持全宽（手机端像素不变）', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _wrap(
          Scaffold(
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AppButton.primary(label: '保存', onPressed: _noop),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.getSize(find.byType(FilledButton)).width, 390 - 32);
      expect(tester.takeException(), isNull);
    });
  });

  group('§4.3 卡片网格', () {
    test('列数映射：<700 单列 / 700–1119 两列 / ≥1120 三列', () {
      expect(AdaptiveGrid.columnsFor(699), 1);
      expect(AdaptiveGrid.columnsFor(700), 2);
      expect(AdaptiveGrid.columnsFor(1119), 2);
      expect(AdaptiveGrid.columnsFor(1120), 3);
      // 1440 视口账本页网格实宽：1440 − 240 侧栏 − 1 分隔线 − 2×32 内边距 = 1135。
      expect(AdaptiveGrid.columnsFor(1135), 3);
    });

    testWidgets('两个子项在 1135 宽下不溢出', (tester) async {
      tester.view.physicalSize = const Size(1135, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _wrap(
          Scaffold(
            body: AdaptiveGrid(
              children: <Widget>[
                for (int i = 0; i < 2; i++)
                  const SizedBox(
                    height: 100,
                    child: ColoredBox(color: Colors.white),
                  ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    // 已修复（P2-1）：子项数少于列数时按子项数收列，尾部不再补空占位列。
    testWidgets(
      '两个子项在 1135 宽下应铺满整行（PRD §4.3 期望）',
      (tester) async {
        tester.view.physicalSize = const Size(1135, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          _wrap(
            Scaffold(
              body: AdaptiveGrid(
                children: <Widget>[
                  for (int i = 0; i < 2; i++)
                    const SizedBox(
                      height: 100,
                      child: ColoredBox(color: Colors.white),
                    ),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final Finder cards = find.byType(ColoredBox);
        for (int i = 0; i < 2; i++) {
          final double width = tester.getSize(cards.at(i)).width;
          expect(width, greaterThan(500));
        }
      },
    );
  });

  group('B3 移动端底部 Tab 覆盖', () {
    test('四个主 Tab 均挂底栏，二级页不挂', () {
      expect(AppDestinations.showsCompactBottomBar('/home'), isTrue);
      expect(AppDestinations.showsCompactBottomBar('/ledgers'), isTrue);
      expect(AppDestinations.showsCompactBottomBar('/stats'), isTrue);
      expect(AppDestinations.showsCompactBottomBar('/profile'), isTrue);
      expect(AppDestinations.showsCompactBottomBar('/settings'), isFalse);
      expect(
        AppDestinations.showsCompactBottomBar('/settings/ai-config'),
        isFalse,
      );
    });
  });
}
