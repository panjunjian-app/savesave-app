import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/breakpoints.dart';
import '../../core/layout_tokens.dart';
import '../../core/theme.dart';
import '../../state/providers.dart';
import '../common/app_buttons.dart';
import '../common/responsive_scaffold.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final compact = context.isCompact;
    final String accountLabel = _accountLabel(user?.loginType, user?.email);

    return ResponsiveScaffold(
      title: '我的',
      maxWidth: AppLayout.readerMaxWidth,
      body: compact
          ? _buildCompact(context, ref, user?.nickname, accountLabel)
          : _buildDesktop(context, ref, user?.nickname, accountLabel),
    );
  }

  /// 手机端：与改造前的 ListView 结构一致（仅导航壳补上了底部 Tab）。
  Widget _buildCompact(
    BuildContext context,
    WidgetRef ref,
    String? nickname,
    String accountLabel,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        _ProfileHeader(nickname: nickname, accountLabel: accountLabel),
        const SizedBox(height: 16),
        const _SettingsEntryCard(),
        const SizedBox(height: 24),
        _SignOutButton(onSignOut: () => _signOut(context, ref)),
      ],
    );
  }

  /// 桌面端：左 320 资料卡 + 退出登录，右 480 入口列表。
  Widget _buildDesktop(
    BuildContext context,
    WidgetRef ref,
    String? nickname,
    String accountLabel,
  ) {
    return ListView(
      padding: context.pagePadding,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              flex: 320,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _ProfileHeader(
                    nickname: nickname,
                    accountLabel: accountLabel,
                    desktop: true,
                  ),
                  const SizedBox(height: AppLayout.cardGap),
                  // 桌面档按钮上限 240（QA P1）：stretch 列会给子级 tight 宽度，
                  // 必须用 Align 松开约束，否则 SizedBox.width 会被父级吞掉变成全宽。
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: AppLayout.buttonMaxWidth,
                      child: AppButton.secondary(
                        label: '退出登录',
                        icon: Icons.logout,
                        onPressed: () => _signOut(context, ref),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppLayout.sectionGap),
            const Expanded(flex: 480, child: _SettingsEntryCard(desktop: true)),
          ],
        ),
        const SizedBox(height: AppLayout.sectionGap),
      ],
    );
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    await ref.read(authServiceProvider).signOut();
    if (context.mounted) {
      ref.read(currentUserProvider.notifier).state = null;
      context.go('/login');
    }
  }

  String _accountLabel(String? loginType, String? email) {
    // 账号类型：云端账号显示邮箱（多端同步），游客显示本地模式
    if (loginType == 'email') {
      return email ?? '云端账号';
    }
    if (loginType == 'wechat') {
      return '微信用户';
    }
    return '本地模式（游客，数据仅在本机）';
  }
}

/// 头像 + 昵称 + 账号类型（手机端与原实现一致，桌面档头像放大到 96）。
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.nickname,
    required this.accountLabel,
    this.desktop = false,
  });

  final String? nickname;
  final String accountLabel;
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    final String name = nickname ?? '未登录';
    final String initial = name.isEmpty ? '游' : name.substring(0, 1);
    if (desktop) {
      return Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: <Widget>[
              CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.goldLight,
                child: Text(
                  initial,
                  style: const TextStyle(fontSize: 32, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                accountLabel,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 200,
                child: AppButton.secondary(
                  label: '编辑资料',
                  icon: Icons.edit_outlined,
                  onPressed: () => context.go('/settings'),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.goldLight,
              child: Text(
                initial,
                style: const TextStyle(fontSize: 24, color: AppColors.primary),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    accountLabel,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 设置 / AI / 同步入口（手机端入口项与改造前一致）。
class _SettingsEntryCard extends StatelessWidget {
  const _SettingsEntryCard({this.desktop = false});

  final bool desktop;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: desktop ? EdgeInsets.zero : null,
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
          if (desktop) ...<Widget>[
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.sync_outlined),
              title: const Text('同步状态'),
              subtitle: const Text('云端账号、上次同步时间与待同步条数'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go('/settings/sync'),
            ),
          ],
        ],
      ),
    );
  }
}

class _SignOutButton extends StatelessWidget {
  const _SignOutButton({required this.onSignOut});

  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return AppButton.secondary(
      label: '退出登录',
      icon: Icons.logout,
      onPressed: onSignOut,
    );
  }
}
