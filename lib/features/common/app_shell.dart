import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/breakpoints.dart';
import '../../core/theme.dart';
import '../../state/providers.dart';
import 'side_nav.dart';
import 'sync_status_badge.dart';

/// 一个导航项的静态描述。
class NavDestinationSpec {
  const NavDestinationSpec({
    required this.label,
    required this.icon,
    required this.path,
    this.selectedIcon,
  });

  /// 文案（与手机端保持一致，PRD §5 备注）。
  final String label;

  /// 未选中图标。
  final IconData icon;

  /// 路由路径（导航一律 `context.go`，不 push，避免栈无限增长）。
  final String path;

  /// 选中图标；为 null 时沿用 [icon]（手机端底部 Tab 即如此，保证像素不变）。
  final IconData? selectedIcon;
}

/// 导航项定义与高亮映射的**唯一来源**（Shared Knowledge §7）。
///
/// 手机端 4 项（底部 Tab）、桌面端 5 项（多一个「账单明细」，修复 D2）。
/// 两套索引互不影响：页面完全不感知索引，子页面按父级高亮。
abstract final class AppDestinations {
  /// 手机端底部 Tab（4 项，图标与文案与改造前完全一致）。
  static const List<NavDestinationSpec> mobile = <NavDestinationSpec>[
    NavDestinationSpec(
      label: '目标',
      icon: Icons.flag_outlined,
      path: '/home',
    ),
    NavDestinationSpec(
      label: '账本',
      icon: Icons.book_outlined,
      path: '/ledgers',
    ),
    NavDestinationSpec(
      label: '统计',
      icon: Icons.bar_chart_outlined,
      path: '/stats',
    ),
    NavDestinationSpec(
      label: '我的',
      icon: Icons.person_outline,
      path: '/profile',
    ),
  ];

  /// 桌面侧栏（5 项，含「账单明细」）。
  static const List<NavDestinationSpec> desktop = <NavDestinationSpec>[
    NavDestinationSpec(
      label: '目标',
      icon: Icons.flag_outlined,
      selectedIcon: Icons.flag,
      path: '/home',
    ),
    NavDestinationSpec(
      label: '账本',
      icon: Icons.book_outlined,
      selectedIcon: Icons.book,
      path: '/ledgers',
    ),
    NavDestinationSpec(
      label: '账单明细',
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long,
      path: '/bills',
    ),
    NavDestinationSpec(
      label: '统计',
      icon: Icons.bar_chart_outlined,
      selectedIcon: Icons.bar_chart,
      path: '/stats',
    ),
    NavDestinationSpec(
      label: '我的',
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      path: '/profile',
    ),
  ];

  /// 手机端高亮索引（0..3）。
  static int mobileIndexFor(String location) {
    if (location.startsWith('/ledgers')) {
      return 1;
    }
    if (location.startsWith('/stats') || location.startsWith('/analysis')) {
      return 2;
    }
    if (location.startsWith('/profile') || location.startsWith('/settings')) {
      return 3;
    }
    return 0;
  }

  /// 桌面端高亮索引（0..4），子页面按父级高亮。
  static int desktopIndexFor(String location) {
    if (location.startsWith('/ledgers')) {
      return 1;
    }
    if (location.startsWith('/bills')) {
      return 2;
    }
    if (location.startsWith('/stats') || location.startsWith('/analysis')) {
      return 3;
    }
    if (location.startsWith('/profile') || location.startsWith('/settings')) {
      return 4;
    }
    return 0;
  }

  /// 手机端是否渲染底部 Tab（白名单，架构 §3.2）。
  ///
  /// `/bills` 刻意不含：改造前账单明细没有底栏，补上会造成额外像素差异（架构 Q1）。
  static bool showsCompactBottomBar(String location) {
    if (location == '/' || location == '/home') {
      return true;
    }
    if (location.startsWith('/goals')) {
      return true;
    }
    if (location == '/ledgers') {
      return true;
    }
    if (location == '/stats') {
      return true;
    }
    if (location == '/profile') {
      return true;
    }
    return false;
  }
}

/// 统一导航壳（架构 §3）：按断点在「底部 Tab / 图标侧栏 / 完整侧栏」之间切换。
///
/// `child` 是 `ShellRoute` 的 navigationShell；`location` 是
/// `GoRouterState.matchedLocation`，用于计算高亮项与底栏显隐。
///
/// 两层 Scaffold 是设计决定：外壳管导航，页面保留自己的
/// Scaffold（AppBar / FAB / SnackBar 依赖它）。
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child, required this.location});

  /// 被包裹的页面。
  final Widget child;

  /// 当前匹配到的路径（`matchedLocation`）。
  final String location;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final breakpoint = Breakpoints.of(constraints.maxWidth);
        if (breakpoint == AppBreakpoint.compact) {
          final bool showBottomBar =
              AppDestinations.showsCompactBottomBar(location);
          return Scaffold(
            body: BreakpointScope(breakpoint: breakpoint, child: child),
            bottomNavigationBar:
                showBottomBar ? _CompactNavigationBar(location: location) : null,
          );
        }

        final int index = AppDestinations.desktopIndexFor(location);
        void onSelect(int value) {
          if (value < 0 || value >= AppDestinations.desktop.length) {
            return;
          }
          context.go(AppDestinations.desktop[value].path);
        }

        return Scaffold(
          body: Row(
            children: <Widget>[
              if (breakpoint == AppBreakpoint.expanded)
                AppSideNav(
                  index: index,
                  onSelect: onSelect,
                  footer: const _SideNavFooter(),
                )
              else
                AppNavigationRail(index: index, onSelect: onSelect),
              const VerticalDivider(
                width: 1,
                thickness: 1,
                color: AppColors.divider,
              ),
              Expanded(
                child: BreakpointScope(breakpoint: breakpoint, child: child),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 手机端底部 Tab：与改造前 3 份 `_*BottomBar` 完全一致（4 项，无选中图标替换）。
class _CompactNavigationBar extends StatelessWidget {
  const _CompactNavigationBar({required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: AppDestinations.mobileIndexFor(location),
      onDestinationSelected: (index) =>
          context.go(AppDestinations.mobile[index].path),
      destinations: AppDestinations.mobile
          .map(
            (spec) => NavigationDestination(
              icon: Icon(spec.icon),
              label: spec.label,
            ),
          )
          .toList(growable: false),
    );
  }
}

/// 侧栏底部固定区：同步状态徽标 + 账号类型（PRD §3.2）。
class _SideNavFooter extends ConsumerWidget {
  const _SideNavFooter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final String subtitle;
    if (user == null) {
      subtitle = '未登录';
    } else if (user.loginType == 'email') {
      subtitle = user.email ?? '云端账号';
    } else if (user.loginType == 'wechat') {
      subtitle = '微信用户';
    } else {
      subtitle = '本地模式（游客）';
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SyncStatusBadge(showLabel: true),
          const SizedBox(height: 8),
          Text(
            user?.nickname ?? '未登录',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
