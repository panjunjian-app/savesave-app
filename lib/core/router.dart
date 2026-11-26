import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/analysis/analysis_report_page.dart';
import '../features/auth/auth_page.dart';
import '../features/auth/upgrade_cloud_page.dart';
import '../features/bill/bill_detail_page.dart';
import '../features/bill/bill_form_page.dart';
import '../features/bill/bill_list_page.dart';
import '../features/common/app_buttons.dart';
import '../features/common/app_shell.dart';
import '../features/goal/goal_detail_page.dart';
import '../features/goal/goal_form_page.dart';
import '../features/home/home_page.dart';
import '../features/ledger/ledger_form_page.dart';
import '../features/ledger/ledger_list_page.dart';
import '../features/settings/ai_config_page.dart';
import '../features/settings/profile_page.dart';
import '../features/settings/settings_page.dart';
import '../features/settings/sync_settings_page.dart';
import '../features/settings/update_page.dart';
import '../features/stats/stats_page.dart';
import '../state/auth_providers.dart';

/// Declarative route table. Widget -> Provider -> Service -> DAO is preserved:
/// pages only talk to Riverpod providers.
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    redirect: (context, state) {
      final loggedIn = ref.read(currentUserProvider) != null;
      final atLogin = state.matchedLocation == '/login';
      if (!loggedIn && !atLogin) {
        return '/login';
      }
      if (loggedIn && atLogin) {
        return '/home';
      }
      return null;
    },
    routes: <RouteBase>[
      // 全屏品牌页 / 引导页：留在导航壳外（架构 §3.3）。
      GoRoute(path: '/login', builder: (context, state) => const AuthPage()),
      GoRoute(
        path: '/upgrade-cloud',
        builder: (context, state) => const UpgradeCloudPage(),
      ),
      // 其余 18 条路由统一进壳：路径、参数、builder 全部不变，只做「移动 + 包壳」。
      ShellRoute(
        builder: (context, state, child) => AppShell(
          location: state.matchedLocation,
          child: child,
        ),
        routes: <RouteBase>[
          GoRoute(path: '/', builder: (context, state) => const HomePage()),
          GoRoute(path: '/home', builder: (context, state) => const HomePage()),
          GoRoute(path: '/goals', builder: (context, state) => const HomePage()),
          GoRoute(
            path: '/goals/create',
            builder: (context, state) => const GoalFormPage(),
          ),
          GoRoute(
            path: '/goals/edit/:id',
            builder: (context, state) => GoalFormPage(
              goalId: state.pathParameters['id'],
            ),
          ),
          GoRoute(
            path: '/goals/:id',
            builder: (context, state) => GoalDetailPage(
              goalId: state.pathParameters['id'] ?? '',
            ),
          ),
          GoRoute(
            path: '/ledgers',
            builder: (context, state) => const LedgerListPage(),
          ),
          GoRoute(
            path: '/ledgers/create',
            builder: (context, state) => const LedgerFormPage(),
          ),
          GoRoute(
            path: '/bills',
            builder: (context, state) => const BillListPage(),
          ),
          GoRoute(
            path: '/bills/new',
            builder: (context, state) => const BillFormPage(),
          ),
          GoRoute(
            path: '/bills/:id',
            builder: (context, state) => BillDetailPage(
              billId: state.pathParameters['id'] ?? '',
            ),
          ),
          GoRoute(path: '/stats', builder: (context, state) => const StatsPage()),
          GoRoute(
            path: '/analysis/report',
            builder: (context, state) => const AnalysisReportPage(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsPage(),
          ),
          GoRoute(
            path: '/settings/ai-config',
            builder: (context, state) => const AiConfigPage(),
          ),
          GoRoute(
            path: '/settings/sync',
            builder: (context, state) => const SyncSettingsPage(),
          ),
          GoRoute(
            path: '/settings/update',
            builder: (context, state) => const UpdatePage(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => _PlaceholderPage(
      title: '页面不存在',
      path: state.uri.toString(),
    ),
  );
});

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.title, required this.path});

  final String title;
  final String path;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.construction_outlined, size: 56, color: Color(0xFFC6A15B)),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text('路由 $path · 页面即将上线'),
            const SizedBox(height: 24),
            AppButton.primary(
              label: '前往首页',
              onPressed: () => context.go('/home'),
            ),
          ],
        ),
      ),
    );
  }
}
