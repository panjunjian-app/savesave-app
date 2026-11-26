import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/breakpoints.dart';
import '../../core/layout_tokens.dart';
import '../../core/theme.dart';

/// 页面骨架（架构 §4 组件 5，本次改造的核心件）。
///
/// 一条纪律：compact（< 600）走 [_compactScaffold] 的**完整旧路径**，
/// 与 v1.2.0 逐字一致；任何桌面样式不得反向注入该分支。
///
/// 桌面档职责：
/// - AppBar 左对齐 + 64px 高 + 1px 分隔线；
/// - 顶栏主操作位（[primaryAction]）与刷新按钮（[onRefresh]）；
/// - 丢弃 FAB（PRD P0-5）；
/// - 内容区 `Center + ConstrainedBox(maxWidth)`。
class ResponsiveScaffold extends StatelessWidget {
  const ResponsiveScaffold({
    super.key,
    required this.title,
    this.body,
    this.actions = const <Widget>[],
    this.primaryAction,
    this.floatingActionButton,
    this.onRefresh,
    this.maxWidth = AppLayout.contentMaxWidth,
    this.fillHeight = false,
    this.breadcrumb,
    this.padding,
    this.backLocation,
    this.showAppBar = true,
  });

  /// 页面标题（compact 居中显示，桌面左对齐）。
  final String title;

  /// 页面主体。
  final Widget? body;

  /// AppBar 右侧附加操作（两档都渲染，例如同步徽标、设置齿轮）。
  final List<Widget> actions;

  /// 桌面档顶栏主操作按钮（如「新建目标」「记一笔」）；compact 忽略。
  final Widget? primaryAction;

  /// 手机端 FAB；桌面档丢弃。
  final Widget? floatingActionButton;

  /// 下拉刷新回调：compact 包 [RefreshIndicator]，桌面渲染顶栏刷新按钮。
  final Future<void> Function()? onRefresh;

  /// 内容区宽度上限（表单 480 / 两列 984 / 阅读 880）。
  final double maxWidth;

  /// 需要 `Column + Expanded` 的页面（统计页）置 true，避免无界高度报错。
  final bool fillHeight;

  /// 桌面档的详情页面包屑文本（如「目标 / 买房」），compact 忽略。
  final String? breadcrumb;

  /// 额外的整体内边距（默认不加，页面自行使用 `context.pagePadding`）。
  final EdgeInsets? padding;

  /// 桌面档返回按钮目标位置（详情 / 二级页）。compact 不渲染返回箭头。
  final String? backLocation;

  /// 是否渲染 AppBar（loading / error 分支可关掉，保持手机端原样）。
  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    final AppBreakpoint? scoped = BreakpointScope.maybeOf(context);
    if (scoped != null) {
      return _buildWithBreakpoint(context, scoped);
    }
    // 无壳页（auth / upgrade_cloud）或单独 pump：自行按可用宽度判定并注入 Scope。
    return LayoutBuilder(
      builder: (context, constraints) {
        final breakpoint = Breakpoints.of(constraints.maxWidth);
        return BreakpointScope(
          breakpoint: breakpoint,
          child: _buildWithBreakpoint(context, breakpoint),
        );
      },
    );
  }

  Widget _buildWithBreakpoint(BuildContext context, AppBreakpoint breakpoint) {
    if (breakpoint == AppBreakpoint.compact) {
      return _compactScaffold();
    }
    return _desktopScaffold(context, breakpoint);
  }

  /// 旧路径：手机端与改造前逐字一致（AppBar 居中、FAB、下拉刷新、无宽度约束）。
  Widget _compactScaffold() {
    final Widget content = body ?? const SizedBox.shrink();
    final Future<void> Function()? refresh = onRefresh;
    return Scaffold(
      appBar: showAppBar ? AppBar(title: Text(title), actions: actions) : null,
      floatingActionButton: floatingActionButton,
      body: refresh == null
          ? content
          : RefreshIndicator(onRefresh: refresh, child: content),
    );
  }

  /// 桌面路径：左对齐顶栏 + 顶栏主操作 + 限宽居中 + 无 FAB。
  Widget _desktopScaffold(BuildContext context, AppBreakpoint breakpoint) {
    final EdgeInsets? extraPadding = padding;
    Widget content = body ?? const SizedBox.shrink();
    if (extraPadding != null) {
      content = Padding(padding: extraPadding, child: content);
    }
    final Widget constrained = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: fillHeight ? SizedBox.expand(child: content) : content,
    );
    return Scaffold(
      appBar: showAppBar ? _buildDesktopAppBar(context, breakpoint) : null,
      body: Align(alignment: Alignment.topCenter, child: constrained),
    );
  }

  AppBar _buildDesktopAppBar(
    BuildContext context,
    AppBreakpoint breakpoint,
  ) {
    final String headerTitle = breadcrumb ?? title;
    final double titleSpacing = breakpoint == AppBreakpoint.medium ? 24 : 32;
    final double titleFontSize = breakpoint == AppBreakpoint.medium ? 20 : 22;
    final String? back = backLocation;
    final Widget? primary = primaryAction;
    final Future<void> Function()? refresh = onRefresh;

    return AppBar(
      centerTitle: false,
      automaticallyImplyLeading: false,
      toolbarHeight: AppLayout.topBarHeight,
      titleSpacing: titleSpacing,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (back != null)
            IconButton(
              icon: const Icon(Icons.arrow_back),
              tooltip: '返回',
              onPressed: () => context.go(back),
            ),
          Flexible(
            child: Text(
              headerTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
      actions: <Widget>[
        if (primary != null) ...<Widget>[
          primary,
          const SizedBox(width: AppLayout.blockGap),
        ],
        if (refresh != null)
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '刷新',
            onPressed: () => refresh(),
          ),
        ...actions,
        const SizedBox(width: 8),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, thickness: 1, color: AppColors.divider),
      ),
    );
  }
}
