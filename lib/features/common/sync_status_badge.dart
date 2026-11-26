import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../state/providers.dart';

/// 同步状态轻量标识（home 页 AppBar，PRD R5：同步中/已同步/离线待同步 N 条）。
///
/// v4：新增可选 [showLabel]（侧栏底部展开态显示文字，默认 false = 现状）。
class SyncStatusBadge extends ConsumerWidget {
  const SyncStatusBadge({super.key, this.showLabel = false});

  /// true 时以「图标 + 文字」形式渲染（用于 240px 侧栏底部）。
  final bool showLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    // 游客/本地模式不展示（数据不上云，PRD G2）。
    if (user == null || user.loginType != 'email') {
      return const SizedBox.shrink();
    }
    final statusAsync = ref.watch(syncStatusProvider);
    final status = statusAsync.asData?.value ?? const SyncStatus(phase: SyncPhase.idle);

    final Widget icon;
    switch (status.phase) {
      case SyncPhase.pulling:
      case SyncPhase.pushing:
        icon = const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
        break;
      case SyncPhase.offline:
        icon = const Icon(
          Icons.cloud_off_outlined,
          size: 18,
          color: AppColors.textSecondary,
        );
        break;
      case SyncPhase.error:
        icon = const Icon(Icons.cloud_off, size: 18, color: AppColors.danger);
        break;
      case SyncPhase.idle:
        icon = status.pendingCount > 0
            ? Badge(
                label: Text('${status.pendingCount}'),
                child: const Icon(
                  Icons.cloud_queue_outlined,
                  size: 18,
                  color: AppColors.gold,
                ),
              )
            : const Icon(
                Icons.cloud_done_outlined,
                size: 18,
                color: AppColors.primary,
              );
        break;
    }

    if (showLabel) {
      return Tooltip(
        message: _tooltip(status),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => ref.read(syncServiceProvider).syncNow(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                icon,
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _label(status),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return IconButton(
      tooltip: _tooltip(status),
      icon: icon,
      onPressed: () => ref.read(syncServiceProvider).syncNow(),
    );
  }

  /// 侧栏文字标签（短句，避免撑破 240px 侧栏）。
  String _label(SyncStatus status) {
    switch (status.phase) {
      case SyncPhase.pulling:
      case SyncPhase.pushing:
        return '同步中…';
      case SyncPhase.offline:
        return '离线模式';
      case SyncPhase.error:
        return '同步失败';
      case SyncPhase.idle:
        return status.pendingCount > 0
            ? '待同步 ${status.pendingCount} 条'
            : '已同步';
    }
  }

  String _tooltip(SyncStatus status) {
    switch (status.phase) {
      case SyncPhase.pulling:
        return '正在拉取云端数据';
      case SyncPhase.pushing:
        return '正在上传本机改动';
      case SyncPhase.offline:
        return '离线模式，数据已保存在本机';
      case SyncPhase.error:
        return '同步失败：${status.errorMessage ?? '稍后自动重试'}';
      case SyncPhase.idle:
        return status.pendingCount > 0
            ? '待同步 ${status.pendingCount} 条'
            : '已同步';
    }
  }
}
