import 'package:flutter/widgets.dart';

/// 三档响应式断点（增量 PRD v4 §2.1）。
///
/// - [compact]  < 600  手机竖屏 → 底部 Tab
/// - [medium]   600–1023 手机横屏 / iPad 竖屏 → 76px 图标侧栏
/// - [expanded] >= 1024 PC 浏览器 → 240px 完整侧栏
enum AppBreakpoint { compact, medium, expanded }

/// 断点阈值与判定口径的**唯一来源**（架构 §2.2）。
///
/// 任何布局判定都必须经由 [Breakpoints.of] 或 `context.breakpoint`，
/// 禁止在页面里写 `width > 900` 这类魔法数字（Shared Knowledge §1）。
abstract final class Breakpoints {
  /// < 600 → compact。
  static const double compactMax = 600;

  /// >= 1024 → expanded。
  static const double expandedMin = 1024;

  /// 按**可用宽度**判定档位：600–1023 → medium。
  static AppBreakpoint of(double width) {
    if (width < compactMax) {
      return AppBreakpoint.compact;
    }
    if (width < expandedMin) {
      return AppBreakpoint.medium;
    }
    return AppBreakpoint.expanded;
  }
}

/// 窗口级断点的单点注入载体（架构 A2）。
///
/// 由 `AppShell`（进壳页）或 `ResponsiveScaffold`（无壳页）注入一次，
/// 页面与子组件通过 `context.breakpoint` 读取，避免每页重复判断
/// `MediaQuery` 造成「窗口档位」与「内容区档位」错位。
class BreakpointScope extends InheritedWidget {
  const BreakpointScope({
    super.key,
    required this.breakpoint,
    required super.child,
  });

  /// 当前窗口级断点。
  final AppBreakpoint breakpoint;

  /// 读取最近的 Scope；没有 Scope 时返回 null。
  static AppBreakpoint? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<BreakpointScope>()
        ?.breakpoint;
  }

  /// 读取最近的 Scope；缺失时按窗口宽度兜底（例如单独 pump 的组件）。
  static AppBreakpoint of(BuildContext context) {
    return maybeOf(context) ??
        Breakpoints.of(MediaQuery.sizeOf(context).width);
  }

  @override
  bool updateShouldNotify(BreakpointScope oldWidget) {
    return oldWidget.breakpoint != breakpoint;
  }
}

/// 用 `LayoutBuilder` 计算断点并注入 [BreakpointScope]（无壳页使用）。
class BreakpointBuilder extends StatelessWidget {
  const BreakpointBuilder({super.key, required this.builder});

  /// 断点已知后的构建回调，`context` 已处于 [BreakpointScope] 之下。
  final Widget Function(BuildContext context, AppBreakpoint breakpoint) builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final breakpoint = Breakpoints.of(constraints.maxWidth);
        return BreakpointScope(
          breakpoint: breakpoint,
          child: Builder(
            builder: (innerContext) => builder(innerContext, breakpoint),
          ),
        );
      },
    );
  }
}

/// 页面与子组件读取断点的统一入口。
extension BreakpointContextX on BuildContext {
  /// 窗口级断点（由壳或页面骨架注入）。
  AppBreakpoint get breakpoint => BreakpointScope.of(this);

  /// 是否手机档（< 600）。
  bool get isCompact => breakpoint == AppBreakpoint.compact;

  /// 是否桌面档（>= 1024）。
  bool get isDesktop => breakpoint == AppBreakpoint.expanded;
}
