import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../state/providers.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.goldLight,
                    child: Text(
                      user?.nickname.substring(0, 1) ?? '游',
                      style: const TextStyle(fontSize: 24, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        user?.nickname ?? '未登录',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        // 账号类型：云端账号显示邮箱（多端同步），游客显示本地模式
                        user?.loginType == 'email'
                            ? (user?.email ?? '云端账号')
                            : (user?.loginType == 'wechat'
                                ? '微信用户'
                                : '本地模式（游客，数据仅在本机）'),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text('设置'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/settings'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.api_outlined),
                  title: const Text('AI 接口配置'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/settings/ai-config'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () async {
              await ref.read(authServiceProvider).signOut();
              if (context.mounted) {
                ref.read(currentUserProvider.notifier).state = null;
                context.go('/login');
              }
            },
            icon: const Icon(Icons.logout),
            label: const Text('退出登录'),
          ),
        ],
      ),
    );
  }
}
