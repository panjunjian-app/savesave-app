import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/breakpoints.dart';
import '../../core/layout_tokens.dart';
import '../../core/theme.dart';
import '../../domain/services/update_service.dart';
import '../../state/providers.dart';
import '../common/app_buttons.dart';
import '../common/responsive_scaffold.dart';

/// 应用内更新页：检查版本 → 下载 APK（带进度）→ 交系统安装器。
///
/// 仅 Android 生效；Web 端刷新页面即最新版，iOS 需重装（无此能力）。
/// v4：桌面档收敛为 560px 居中卡片；Web 端隐藏「下载 / 安装」按钮。
class UpdatePage extends ConsumerStatefulWidget {
  const UpdatePage({super.key});

  @override
  ConsumerState<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends ConsumerState<UpdatePage> {
  @override
  void initState() {
    super.initState();
    // 进入页面即静默检查一次，避免用户还要多点一下
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final service = ref.read(updateServiceProvider);
      service.primeVersion();
      if (service.isSupported) {
        service.check(silent: false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = ref.watch(updateServiceProvider);
    return ResponsiveScaffold(
      title: '检查更新',
      maxWidth: AppLayout.updateCardMaxWidth,
      backLocation: '/settings',
      body: StreamBuilder<UpdateState>(
        stream: service.stream,
        initialData: service.state,
        builder: (context, snapshot) {
          final state = snapshot.data ?? const UpdateState();
          return context.isCompact
              ? _buildCompactBody(service, state)
              : _buildDesktopBody(service, state);
        },
      ),
    );
  }

  /// 手机端：与改造前逐字一致的列表结构。
  Widget _buildCompactBody(UpdateService service, UpdateState state) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '当前版本 ${state.currentVersion.isEmpty ? '读取中…' : state.currentVersion}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                _buildStatus(context, service, state),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (state.release != null) _buildReleaseCard(context, state),
        const SizedBox(height: 16),
        AppButton.primary(
          label: '检查更新',
          icon: Icons.refresh,
          onPressed: state.phase == UpdatePhase.checking ||
                  state.phase == UpdatePhase.downloading
              ? null
              : () => service.check(silent: false),
        ),
        const SizedBox(height: 24),
        _buildNotes(),
      ],
    );
  }

  /// 桌面端：560 居中卡片，左版本信息 ｜ 右更新按钮 240。
  Widget _buildDesktopBody(UpdateService service, UpdateState state) {
    final bool busy = state.phase == UpdatePhase.checking ||
        state.phase == UpdatePhase.downloading;
    final bool hasRelease = state.phase == UpdatePhase.available &&
        state.release != null;
    return ListView(
      padding: context.pagePadding,
      children: <Widget>[
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '当前版本 ${state.currentVersion.isEmpty ? '读取中…' : state.currentVersion}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      _buildStatus(context, service, state),
                      if (state.release != null &&
                          state.release!.notes.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 12),
                        Text(
                          state.release!.notes,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(height: 1.6),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppLayout.sectionGap),
                SizedBox(
                  width: AppLayout.buttonMaxWidth,
                  child: AppButton.primary(
                    label: '检查更新',
                    icon: Icons.refresh,
                    backgroundColor: hasRelease ? AppColors.gold : null,
                    onPressed: busy ? null : () => service.check(silent: false),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (state.release != null) ...<Widget>[
          const SizedBox(height: AppLayout.cardGap),
          _buildReleaseCard(context, state, desktop: true),
        ],
        const SizedBox(height: AppLayout.sectionGap),
        _buildNotes(),
        const SizedBox(height: AppLayout.sectionGap),
      ],
    );
  }

  Widget _buildNotes() {
    return const Text(
      '说明：\n'
      '· 只有 Android 版支持应用内更新，下载后点「安装」即可，不会丢失数据\n'
      '· 网页版刷新页面就是最新代码\n'
      '· 更新包从 Cloudflare CDN 下载，安装前会校验文件完整性',
      style: TextStyle(color: AppColors.textSecondary, height: 1.6),
    );
  }

  Widget _buildStatus(BuildContext context, UpdateService service, UpdateState state) {
    switch (state.phase) {
      case UpdatePhase.idle:
        return Text(
          state.message ?? (service.isSupported ? '点下方按钮检查是否有新版本' : '当前平台不支持应用内更新'),
          style: const TextStyle(color: AppColors.textSecondary),
        );
      case UpdatePhase.checking:
        return const Row(
          children: <Widget>[
            SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
            SizedBox(width: 12),
            Text('正在检查…'),
          ],
        );
      case UpdatePhase.upToDate:
        return const Text('已是最新版本 ✅', style: TextStyle(color: AppColors.primary));
      case UpdatePhase.available:
        return Text(
          '发现新版本 ${state.release?.versionName ?? ''}',
          style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600),
        );
      case UpdatePhase.downloading:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('正在下载新版本… ${(state.progress * 100).toStringAsFixed(0)}%'),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: state.progress),
          ],
        );
      case UpdatePhase.verifying:
        return const Text('正在校验安装包…');
      case UpdatePhase.ready:
        return Text(state.message ?? '下载完成，可以安装');
      case UpdatePhase.installing:
        return const Text('正在唤起系统安装器…');
      case UpdatePhase.failed:
        return Text(
          state.message ?? '操作失败，请重试',
          style: const TextStyle(color: AppColors.danger),
        );
    }
  }

  Widget _buildReleaseCard(
    BuildContext context,
    UpdateState state, {
    bool desktop = false,
  }) {
    final release = state.release!;
    final bool hasLocalApk = state.localApkPath != null;
    final bool busy = state.phase == UpdatePhase.downloading;
    return Card(
      margin: desktop ? EdgeInsets.zero : null,
      child: Padding(
        padding: EdgeInsets.all(desktop ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('新版本 ${release.versionName}',
                style: Theme.of(context).textTheme.titleMedium),
            if (release.sizeLabel.isNotEmpty) ...<Widget>[
              const SizedBox(height: 4),
              Text('安装包 ${release.sizeLabel}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
            if (release.notes.isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              Text(release.notes, style: const TextStyle(height: 1.5)),
            ],
            const SizedBox(height: 16),
            if (kIsWeb)
              // Web 端无安装包概念：隐藏 APK 按钮，提示刷新即最新（PRD §5 第 16 页）。
              const Text(
                '网页版无需下载安装包，刷新页面即可使用最新版本。',
                style: TextStyle(color: AppColors.primary, fontSize: 13),
              )
            else if (!hasLocalApk)
              AppButton.primary(
                label: '下载并安装',
                icon: Icons.download,
                onPressed: busy ? null : () => _download(),
              )
            else
              AppButton.primary(
                label: '立即安装',
                icon: Icons.install_mobile,
                onPressed: () => ref.read(updateServiceProvider).installApk(),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _download() async {
    final service = ref.read(updateServiceProvider);
    final file = await service.downloadApk();
    if (file != null && mounted) {
      await service.installApk();
    }
  }
}
