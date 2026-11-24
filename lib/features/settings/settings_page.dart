import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/config.dart';
import '../../core/theme.dart';
import '../../state/providers.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Card(
            child: Column(
              children: <Widget>[
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
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.info_outline, color: AppColors.gold),
                  title: const Text('关于'),
                  subtitle: Text('省省钱，存存钱 $_version'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_forever_outlined, color: AppColors.danger),
                  title: const Text('清空全部数据'),
                  onTap: _clearAllData,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text(
              '本地优先 · 数据仅保存在你的设备上',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
