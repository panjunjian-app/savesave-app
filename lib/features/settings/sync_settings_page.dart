import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../state/providers.dart';

/// 同步设置页（F11）：立即同步、状态/上次同步时间/失败原因、待同步计数。
class SyncSettingsPage extends ConsumerWidget {
  const SyncSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(syncStatusProvider);
    final status = statusAsync.asData?.value;

    return Scaffold(
      appBar: AppBar(title: const Text('数据同步')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      _phaseIcon(status),
                      const SizedBox(width: 12),
                      Text(
                        _phaseLabel(status),
                        style: Theme.of(context).textTheme.titleMedium,
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
                      style: const TextStyle(
                        color: AppColors.danger,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: <Widget>[
                ListTile(
                  leading:
                      const Icon(Icons.sync, color: AppColors.primary),
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
      ),
    );
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
          Text(value),
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
