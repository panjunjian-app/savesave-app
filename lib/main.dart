import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router.dart';
import 'core/theme.dart';
import 'state/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 顶层 ProviderContainer：启动引导需要先恢复会话再挂载 UI。
  final container = ProviderContainer();

  // 1) 恢复会话：云端（secure storage）→ 本机账号/游客（离线优先，S10）。
  try {
    final user = await container.read(authServiceProvider).restoreLocalUser();
    if (user != null) {
      container.read(currentUserProvider.notifier).state = user;
    }
  } catch (_) {
    // 恢复失败不阻塞启动：停留在登录页允许重试。
  }

  // 2) 激活同步编排：登录态监听、写操作防抖推送、联网恢复触发、前台定时。
  //    云端会话存在时编排器会自动执行增量首拉（水位 0 → 全量）。
  container.read(syncOrchestratorProvider);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const SaveSaveApp(),
    ),
  );
}

/// Root widget. The database and services are opened lazily by providers.
class SaveSaveApp extends ConsumerWidget {
  const SaveSaveApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: '省省钱，存存钱',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
