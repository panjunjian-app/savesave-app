import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/breakpoints.dart';
import '../../core/layout_tokens.dart';
import '../../core/theme.dart';
import '../../state/providers.dart';
import '../common/app_buttons.dart';
import '../common/responsive_scaffold.dart';

/// 同步设置页（F11）：立即同步、状态/上次同步时间/失败原因、待同步计数。
class SyncSettingsPage extends ConsumerWidget {
  const SyncSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(syncStatusProvider);
    final status = statusAsync.asData?.value;

    return ResponsiveScaffold(
      title: '数据同步',
      maxWidth: AppLayout.formTwoColumnMaxWidth,
      backLocation: '/settings',
      body: context.isCompact
          ? _buildCompactBody(context, ref, status)
          : _buildDesktopBody(context, ref, status),
    );
  }

  /// 手机端：与改造前逐字一致的列表结构。
  Widget _buildCompactBody(
    BuildContext context,
    WidgetRef ref,
    SyncStatus? status,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        _statusCard(context, status),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.sync, color: AppColors.primary),
                title: const Text('立即同步'),
                subtitle: const Text('上传本机改动并拉取云端最新数据'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  await ref.read(syncServiceProvider).syncNow();
                  ref.invalidate(pendingSyncCountProvider);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(
                  Icons.cloud_upload_outlined,
                  color: AppColors.gold,
                ),
                title: const Text('升级为云端账号'),
                subtitle: const Text('把本机已有数据带入云端，开启多端同步'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/upgrade-cloud'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Center(
          child: Text(
            '本地优先 · 云端为同一账号的权威副本 · AI Key 永不上云',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ),
      ],
    );
  }

  /// 桌面端：左 480 账号卡 + 退出登录 ｜ 右 480 同步状态与操作。
  Widget _buildDesktopBody(
    BuildContext context,
    WidgetRef ref,
    SyncStatus? status,
  ) {
    return ListView(
      padding: context.pagePadding,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _accountCard(context, ref),
                  const SizedBox(height: AppLayout.cardGap),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AppButton.secondary(
                      label: '退出登录',
                      icon: Icons.logout,
                      onPressed: () => _signOut(context, ref),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppLayout.sectionGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _statusCard(context, status),
                  const SizedBox(height: AppLayout.cardGap),
                  Card(
                    margin: EdgeInsets.zero,
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          leading: const Icon(
                            Icons.sync,
                            color: AppColors.primary,
                          ),
                          title: const Text('立即同步'),
                          subtitle: const Text('上传本机改动并拉取云端最新数据'),
                          onTap: () async {
                            await ref.read(syncServiceProvider).syncNow();
                            ref.invalidate(pendingSyncCountProvider);
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(
                            Icons.cloud_upload_outlined,
                            color: AppColors.gold,
                          ),
                          title: const Text('升级为云端账号'),
                          subtitle: const Text('把本机已有数据带入云端，开启多端同步'),
                          onTap: () => context.go('/upgrade-cloud'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppLayout.sectionGap),
        const Center(
          child: Text(
            '本地优先 · 云端为同一账号的权威副本 · AI Key 永不上云',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _statusCard(BuildContext context, SyncStatus? status) {
    final bool syncing = status?.phase == SyncPhase.pulling ||
        status?.phase == SyncPhase.pushing;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                _phaseIcon(status),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _phaseLabel(status),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _infoRow(
              '上次成功同步',
              status?.lastSyncAt == null
                  ? '从未同步'
                  : _formatTime(status!.lastSyncAt!),
            ),
            _infoRow(
              '待同步记录',
              status == null ? '—' : '${status.pendingCount} 条',
            ),
            _infoRow('同步模式', '自动（打开应用 / 联网后 / 本地修改 5 秒内）'),
            if (status?.errorMessage != null) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                '最近一次失败：${status!.errorMessage}',
                style: const TextStyle(color: AppColors.danger, fontSize: 13),
              ),
            ],
            if (syncing) ...<Widget>[
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }

  /// 账号卡：头像 / 昵称 / 邮箱（登录方式）。
  Widget _accountCard(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final String nickname = user?.nickname ?? '未登录';
    final String initial = nickname.isEmpty ? '游' : nickname.substring(0, 1);
    final String loginLabel;
    if (user == null) {
      loginLabel = '未登录';
    } else if (user.loginType == 'email') {
      loginLabel = user.email ?? '云端账号';
    } else if (user.loginType == 'wechat') {
      loginLabel = '微信用户';
    } else {
      loginLabel = '本地模式（游客）';
    }
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.goldLight,
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontSize: 18,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        nickname,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        loginLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _infoRow('登录方式', user?.loginType == 'email' ? '邮箱密码' : '本机账号'),
          ],
        ),
      ),
    );
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    await ref.read(authServiceProvider).signOut();
    if (context.mounted) {
      ref.read(currentUserProvider.notifier).state = null;
      context.go('/login');
    }
  }

  Widget _phaseIcon(SyncStatus? status) {
    switch (status?.phase ?? SyncPhase.offline) {
      case SyncPhase.pulling:
      case SyncPhase.pushing:
        return const SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 2.4),
        );
      case SyncPhase.error:
        return const Icon(Icons.cloud_off, color: AppColors.danger, size: 28);
      case SyncPhase.offline:
        return const Icon(
          Icons.cloud_off_outlined,
          color: AppColors.textSecondary,
          size: 28,
        );
      case SyncPhase.idle:
        return const Icon(Icons.cloud_done, color: AppColors.primary, size: 28);
    }
  }

  String _phaseLabel(SyncStatus? status) {
    switch (status?.phase ?? SyncPhase.offline) {
      case SyncPhase.pulling:
        return '正在拉取云端数据…';
      case SyncPhase.pushing:
        return '正在上传本机改动…';
      case SyncPhase.error:
        return '同步失败，将自动重试';
      case SyncPhase.offline:
        return '本地模式（离线可用，联网后自动同步）';
      case SyncPhase.idle:
        return status != null && status.pendingCount > 0
            ? '已同步，待上传 ${status.pendingCount} 条'
            : '已同步';
    }
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Flexible(child: Text(value, textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final local = time.toLocal();
    String two(int value) => value.toString().padLeft(2, '0');
    return '${local.year}-${two(local.month)}-${two(local.day)} '
        '${two(local.hour)}:${two(local.minute)}';
  }
}
