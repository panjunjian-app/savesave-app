import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router.dart';
import 'core/theme.dart';
import 'domain/services/update_service.dart';
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

  // 3) 后台静默检查新版本（仅 Android；失败不打扰用户）。
  container.read(updateServiceProvider).check(silent: true);

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

  static final GlobalKey<ScaffoldMessengerState> _messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: '省省钱，存存钱',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      routerConfig: router,
      scaffoldMessengerKey: _messengerKey,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return _UpdateNotifier(
          messengerKey: _messengerKey,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

/// 监听更新状态，发现新版本时用一条 SnackBar 提示（不打断当前操作）。
class _UpdateNotifier extends ConsumerStatefulWidget {
  const _UpdateNotifier({required this.messengerKey, required this.child});

  final GlobalKey<ScaffoldMessengerState> messengerKey;
  final Widget child;

  @override
  ConsumerState<_UpdateNotifier> createState() => _UpdateNotifierState();
}

class _UpdateNotifierState extends ConsumerState<_UpdateNotifier> {
  bool _announced = false;

  @override
  void initState() {
    super.initState();
    // 启动时容器已发起一次检查；这里只负责把结果转成提示。
    ref.read(updateServiceProvider).stream.listen((state) {
      if (!mounted || _announced) {
        return;
      }
      if (state.phase == UpdatePhase.available && state.release != null) {
        _announced = true;
        final messenger = widget.messengerKey.currentState;
        if (messenger == null) {
          return;
        }
        messenger.showSnackBar(
          SnackBar(
            content: Text('发现新版本 ${state.release!.versionName}，可直接在 App 内更新'),
            duration: const Duration(seconds: 8),
            action: SnackBarAction(
              label: '去更新',
              onPressed: () => ref.read(goRouterProvider).go('/settings/update'),
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
