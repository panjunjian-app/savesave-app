import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savesave/core/breakpoints.dart';
import 'package:savesave/core/layout_tokens.dart';
import 'package:savesave/features/common/adaptive_grid.dart';
import 'package:savesave/features/common/app_buttons.dart';
import 'package:savesave/features/common/app_shell.dart';
import 'package:savesave/features/common/data_table_view.dart';
import 'package:savesave/features/common/responsive_scaffold.dart';
import 'package:savesave/features/common/side_nav.dart';

/// 响应式导航壳冒烟测试（架构 §10.1 建议项，**新增**测试，不改动既有 129 例）。
///
/// 覆盖：三档导航形态、侧栏宽度 240、内容区上限 1200、按钮宽度上限 240、
/// 网格列数映射。不含数据库依赖，因此可在无插件的测试环境直接 pump。
Widget _wrap(Widget child) {
  return ProviderScope(child: MaterialApp(home: child));
}

/// 探针页面：只用共享件，不触达 Provider / 数据库。
class _ProbePage extends StatelessWidget {
  const _ProbePage();

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: '探针页面',
      primaryAction: AppButton.primary(label: '新建', onPressed: () {}),
      maxWidth: AppLayout.contentMaxWidth,
      body: ListView(
        padding: context.pagePadding,
        children: const <Widget>[
          SizedBox(height: 120, child: ColoredBox(color: Colors.white)),
          AdaptiveGrid(
            children: <Widget>[
              SizedBox(height: 80, child: ColoredBox(color: Colors.white)),
              SizedBox(height: 80, child: ColoredBox(color: Colors.white)),
              SizedBox(height: 80, child: ColoredBox(color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }
}

void main() {
  testWidgets('390×844（compact）：底部 Tab 可见、无侧栏、内容不限宽', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _wrap(const AppShell(location: '/home', child: _ProbePage())),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(AppSideNav), findsNothing);
    expect(find.byType(AppNavigationRail), findsNothing);
    // 手机端不施加 1200px 约束：内容铺满 390，且无 FAB 之外的顶栏主按钮。
    expect(tester.getSize(find.byType(ListView)).width, 390);
    expect(find.byType(FilledButton), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('768×1024（medium）：76px 图标侧栏、无底部 Tab', (tester) async {
    tester.view.physicalSize = const Size(768, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _wrap(const AppShell(location: '/ledgers', child: _ProbePage())),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AppSideNav), findsNothing);
    expect(find.byType(AppNavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(
      tester.getSize(find.byType(AppNavigationRail)).width,
      AppLayout.railWidth,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('1440×900（expanded）：240px 侧栏、内容 ≤1200、按钮 ≤240', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _wrap(const AppShell(location: '/bills', child: _ProbePage())),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AppSideNav), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    // 侧栏 240（PRD §3.1 / 验收 A3）。
    expect(
      tester.getSize(find.byType(AppSideNav)).width,
      AppLayout.sideNavWidth,
    );
    // 内容区宽度受控（验收 A2）：1440 − 240 侧栏 − 1 分隔线 = 1199。
    expect(
      tester.getSize(find.byType(ListView)).width,
      lessThanOrEqualTo(AppLayout.contentMaxWidth),
    );
    // FAB 在桌面档不出现（P0-5）；主按钮宽度 ≤240（A4）。
    expect(find.byType(FloatingActionButton), findsNothing);
    expect(
      tester.getSize(find.byType(FilledButton).first).width,
      lessThanOrEqualTo(AppLayout.buttonMaxWidth),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('表格在窄容器内自动降级，不出现横向溢出', (tester) async {
    for (final double width in <double>[700, 1100]) {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(
        _wrap(
          Scaffold(
            body: AppTableView<int>(
              rows: const <int>[1, 2, 3],
              columns: <AppTableColumn<int>>[
                for (int i = 0; i < 6; i++)
                  AppTableColumn<int>(
                    label: '列$i',
                    minWidth: 120,
                    cell: (context, row) => Text('值$i-$row'),
                  ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
    addTearDown(tester.view.reset);
  });

  testWidgets('表单按钮组：手机端纵排全宽、桌面端右对齐且 ≤240', (tester) async {
    Widget bar() => Scaffold(
          body: FormActionBar(
            secondary: AppButton.text(label: '取消', onPressed: () {}),
            primary: AppButton.primary(label: '保存', onPressed: () {}),
          ),
        );

    tester.view.physicalSize = const Size(390, 800);
    tester.view.devicePixelRatio = 1.0;
    await tester.pumpWidget(_wrap(bar()));
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(FilledButton)).width, 390);
    expect(tester.takeException(), isNull);

    tester.view.physicalSize = const Size(1440, 900);
    await tester.pumpWidget(_wrap(bar()));
    await tester.pumpAndSettle();
    expect(
      tester.getSize(find.byType(FilledButton)).width,
      lessThanOrEqualTo(AppLayout.buttonMaxWidth),
    );
    expect(tester.takeException(), isNull);
    addTearDown(tester.view.reset);
  });

  test('断点与导航映射口径', () {
    expect(Breakpoints.of(599), AppBreakpoint.compact);
    expect(Breakpoints.of(600), AppBreakpoint.medium);
    expect(Breakpoints.of(1023), AppBreakpoint.medium);
    expect(Breakpoints.of(1024), AppBreakpoint.expanded);

    // 手机端 4 项、桌面端 5 项，子页面按父级高亮。
    expect(AppDestinations.mobile.length, 4);
    expect(AppDestinations.desktop.length, 5);
    expect(AppDestinations.mobileIndexFor('/settings/ai-config'), 3);
    expect(AppDestinations.desktopIndexFor('/settings/ai-config'), 4);
    expect(AppDestinations.desktopIndexFor('/bills/new'), 2);
    // /bills 刻意不在手机端底栏白名单内（架构 Q1）。
    expect(AppDestinations.showsCompactBottomBar('/bills'), isFalse);
    expect(AppDestinations.showsCompactBottomBar('/home'), isTrue);
    expect(AppDestinations.showsCompactBottomBar('/goals/create'), isTrue);
    expect(AppDestinations.showsCompactBottomBar('/bills/new'), isFalse);

    // 网格列数映射：>=1120 → 3 列、>=700 → 2 列、否则单列。
    expect(AdaptiveGrid.columnsFor(1136), 3);
    expect(AdaptiveGrid.columnsFor(900), 2);
    expect(AdaptiveGrid.columnsFor(420), 1);
    // compact 页面内边距恒为 all(16)。
    expect(
      AppLayout.pagePadding(AppBreakpoint.compact),
      const EdgeInsets.all(16),
    );
  });
}
