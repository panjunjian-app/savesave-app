import 'package:flutter/material.dart';

import '../../core/layout_tokens.dart';
import '../../core/theme.dart';
// 导航项常量的唯一来源在 app_shell.dart（Shared Knowledge §7）。
import 'app_shell.dart';

/// 展开态侧栏（240px，PRD §3.2）。
///
/// 结构：品牌区（72）+ 导航项（44 × 5）+ 弹性留白 + 底部固定区（同步徽标 / 账号）。
/// 选中态为墨绿 8% 底 + 左侧 3px 墨绿指示条；金色不用于选中态。
/// 折叠态（P2-1）本期不启用，宽度常量已在 [AppLayout.sideNavCollapsedWidth] 预留。
class AppSideNav extends StatelessWidget {
  const AppSideNav({
    super.key,
    required this.index,
    required this.onSelect,
    this.footer,
  });

  /// 当前高亮的导航项索引（桌面 5 项）。
  final int index;

  /// 点击导航项回调。
  final ValueChanged<int> onSelect;

  /// 底部固定区（同步状态徽标 + 账号信息）。
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final Widget? footerWidget = footer;
    const List<NavDestinationSpec> specs = AppDestinations.desktop;
    return Container(
      width: AppLayout.sideNavWidth,
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const _BrandBar(),
          const SizedBox(height: 8),
          for (int i = 0; i < specs.length; i++)
            _SideNavItem(
              spec: specs[i],
              selected: i == index,
              onTap: () => onSelect(i),
            ),
          const Spacer(),
          if (footerWidget != null) footerWidget,
        ],
      ),
    );
  }
}

/// 品牌区：图标字标 + 「省省钱，存存钱」。
class _BrandBar extends StatelessWidget {
  const _BrandBar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppLayout.brandBarHeight,
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 12),
        child: Row(
          children: <Widget>[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.savings_outlined,
                size: 19,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                '省省钱，存存钱',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 单个导航项：高 44、圆角 10、图标 20 + 文字 14。
class _SideNavItem extends StatelessWidget {
  const _SideNavItem({
    required this.spec,
    required this.selected,
    required this.onTap,
  });

  final NavDestinationSpec spec;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color foreground =
        selected ? AppColors.primary : AppColors.textSecondary;
    final IconData icon = selected ? (spec.selectedIcon ?? spec.icon) : spec.icon;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: selected
            ? AppColors.primary.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          hoverColor: AppColors.primary.withValues(alpha: 0.04),
          child: SizedBox(
            height: AppLayout.navItemHeight,
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: AppLayout.navIndicatorWidth,
                  height: 20,
                  child: selected
                      ? const DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.all(Radius.circular(2)),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 9),
                Icon(icon, size: 20, color: foreground),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    spec.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: foreground,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// medium 档的 76px 图标栏：直接用 Material [NavigationRail]（自带 Tooltip 与语义）。
class AppNavigationRail extends StatelessWidget {
  const AppNavigationRail({
    super.key,
    required this.index,
    required this.onSelect,
  });

  /// 当前高亮的导航项索引（桌面 5 项）。
  final int index;

  /// 点击导航项回调。
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: index,
      onDestinationSelected: onSelect,
      labelType: NavigationRailLabelType.none,
      minWidth: AppLayout.railWidth,
      backgroundColor: AppColors.surface,
      groupAlignment: -0.92,
      destinations: AppDestinations.desktop
          .map(
            (spec) => NavigationRailDestination(
              icon: Tooltip(message: spec.label, child: Icon(spec.icon)),
              selectedIcon: Tooltip(
                message: spec.label,
                child: Icon(spec.selectedIcon ?? spec.icon),
              ),
              label: Text(spec.label),
            ),
          )
          .toList(growable: false),
    );
  }
}
