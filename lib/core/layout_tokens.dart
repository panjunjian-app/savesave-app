import 'package:flutter/widgets.dart';

import 'breakpoints.dart';

/// 布局数值的**唯一来源**（架构 §2.3）。
///
/// 页面内禁止再出现宽度 / 间距魔法数字：水平方向用 [AppLayout.pagePadding]，
/// 卡片内距用 [AppLayout.cardPadding]，区块间距 24、卡片间距 16。
abstract final class AppLayout {
  // ---- 导航壳 ----
  /// 展开侧栏宽度（PRD §3.1）。
  static const double sideNavWidth = 240;

  /// 折叠侧栏宽度（P2-1 预留，本期不启用）。
  static const double sideNavCollapsedWidth = 76;

  /// medium 档 `NavigationRail` 宽度。
  static const double railWidth = 76;

  /// 侧栏品牌区高度。
  static const double brandBarHeight = 72;

  /// 侧栏导航项高度。
  static const double navItemHeight = 44;

  /// 侧栏选中态左侧指示条宽度。
  static const double navIndicatorWidth = 3;

  // ---- 内容区上限 ----
  /// 整页内容上限（验收 A2）。
  static const double contentMaxWidth = 1200;

  /// 表单单列上限（验收 A5）。
  static const double formMaxWidth = 480;

  /// 两列表单上限：2 × 480 + 24 间距。
  static const double formTwoColumnMaxWidth = 984;

  /// 详情 / 报告 / 设置类阅读列上限（验收 A6）。
  static const double readerMaxWidth = 880;

  /// 检查更新页卡片上限。
  static const double updateCardMaxWidth = 560;

  /// 「我的」页左侧资料卡宽度。
  static const double profileSideWidth = 320;

  /// 统计页左侧筛选栏宽度。
  static const double statsFilterWidth = 240;

  /// 桌面「左标签 + 右控件」的标签列宽度。
  static const double fieldLabelWidth = 120;

  /// 顶部操作条高度（PRD §3.3）。
  static const double topBarHeight = 64;

  // ---- 按钮（验收 A4：单按钮 <= 240）----
  static const double buttonMaxWidth = 240;
  static const double buttonMinWidth = 120;
  static const double buttonHeight = 48;

  // ---- 表格 ----
  static const double tableRowHeight = 52;
  static const double tableRowCompactHeight = 40;
  static const double tableHeaderHeight = 44;

  // ---- 8 的倍数栅格 ----
  static const double cardGap = 16;
  static const double sectionGap = 24;
  static const double blockGap = 12;

  /// 页面内边距：compact 恒为 `all(16)`（手机端逐像素不变）。
  ///
  /// [bottom] 用于避开 FAB / 底部安全区的额外留白。
  static EdgeInsets pagePadding(AppBreakpoint breakpoint, {double bottom = 0}) {
    switch (breakpoint) {
      case AppBreakpoint.compact:
        return EdgeInsets.fromLTRB(16, 16, 16, bottom == 0 ? 16 : bottom);
      case AppBreakpoint.medium:
        return EdgeInsets.fromLTRB(24, 20, 24, bottom == 0 ? 20 : bottom);
      case AppBreakpoint.expanded:
        return EdgeInsets.fromLTRB(32, 24, 32, bottom == 0 ? 24 : bottom);
    }
  }

  /// 卡片内边距：compact 20 / 桌面 24（PRD §3.1）。
  static double cardPadding(AppBreakpoint breakpoint) {
    return breakpoint == AppBreakpoint.compact ? 20 : 24;
  }
}

/// 布局 token 的上下文快捷方式。
extension AppLayoutContextX on BuildContext {
  /// 当前档位的页面内边距（compact 恒为 16）。
  EdgeInsets get pagePadding => AppLayout.pagePadding(breakpoint);

  /// 当前档位的卡片内边距。
  double get cardPadding => AppLayout.cardPadding(breakpoint);
}
