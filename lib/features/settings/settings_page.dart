import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/breakpoints.dart';
import '../../core/config.dart';
import '../../core/layout_tokens.dart';
import '../../core/theme.dart';
import '../../state/providers.dart';
import '../common/app_buttons.dart';
import '../common/responsive_scaffold.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  String _version = AppConfig.appName;

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() => _version = 'v${info.version}+${info.buildNumber}');
    }
  }

  Future<void> _clearAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空全部数据'),
        content: const Text(
          '将删除本机所有账本、账单、目标与里程碑，且无法恢复。请先导出备份（后续版本支持）。确定继续吗？',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确认清空', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    final db = ref.read(appDatabaseProvider);
    await db.transaction(() async {
      await db.billDao.deleteAll();
      await db.goalDao.deleteAll();
      await db.ledgerDao.deleteAll();
      await db.categoryDao.deleteAll();
      await db.analysisReportDao.deleteAll();
    });
    ref.read(balanceCacheProvider).clear();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已清空本机数据')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: '设置',
      maxWidth: AppLayout.readerMaxWidth,
      backLocation: '/profile',
      body: context.isCompact ? _buildCompactBody() : _buildDesktopBody(),
    );
  }

  /// 手机端：与改造前逐字一致的列表结构。
  Widget _buildCompactBody() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        _primaryGroupCard(),
        const SizedBox(height: 16),
        _aboutGroupCard(),
        const SizedBox(height: 24),
        const Center(
          child: Text(
            '本地优先 · 数据仅保存在你的设备上',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ),
      ],
    );
  }

  /// 桌面端：两栏分组 + 危险操作独立卡片（红框）+ 版权居中。
  Widget _buildDesktopBody() {
    return ListView(
      padding: context.pagePadding,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(child: _primaryGroupCard(desktop: true)),
            const SizedBox(width: AppLayout.sectionGap),
            Expanded(child: _aboutGroupCard(desktop: true)),
          ],
        ),
        const SizedBox(height: AppLayout.sectionGap),
        _dangerCard(),
        const SizedBox(height: AppLayout.sectionGap),
        const Center(
          child: Text(
            '本地优先 · 数据仅保存在你的设备上',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _primaryGroupCard({bool desktop = false}) {
    return Card(
      margin: desktop ? EdgeInsets.zero : null,
      child: Column(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.sync, color: AppColors.primary),
            title: const Text('数据同步'),
            subtitle: const Text('云端账号、多端同步状态'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/settings/sync'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.api, color: AppColors.primary),
            title: const Text('AI 接口配置'),
            subtitle: const Text('BYOK Key、连接测试与授权范围'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/settings/ai-config'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.person_outline, color: AppColors.primary),
            title: const Text('个人信息'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/profile'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.system_update, color: AppColors.primary),
            title: const Text('检查更新'),
            subtitle: const Text('有新版本时可直接在 App 内下载安装'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/settings/update'),
          ),
        ],
      ),
    );
  }

  Widget _aboutGroupCard({bool desktop = false}) {
    return Card(
      margin: desktop ? EdgeInsets.zero : null,
      child: Column(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.info_outline, color: AppColors.gold),
            title: const Text('关于'),
            subtitle: Text('省省钱，存存钱 $_version'),
          ),
          if (!desktop) ...<Widget>[
            const Divider(height: 1),
            ListTile(
              leading: const Icon(
                Icons.delete_forever_outlined,
                color: AppColors.danger,
              ),
              title: const Text('清空全部数据'),
              onTap: _clearAllData,
            ),
          ],
        ],
      ),
    );
  }

  /// 桌面端危险操作独立卡片：红色边框 + 按钮不全宽。
  Widget _dangerCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppColors.danger),
      ),
      child: Row(
        children: <Widget>[
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '清空全部数据',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.danger,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  '删除本机所有账本、账单、目标与里程碑，操作不可撤销。',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppLayout.sectionGap),
          AppButton.danger(label: '清空全部数据', onPressed: _clearAllData),
        ],
      ),
    );
  }
}
