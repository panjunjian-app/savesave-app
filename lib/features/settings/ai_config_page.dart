import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme.dart';
import '../../data/services/ai_client.dart';
import '../../state/providers.dart';

class AiConfigPage extends ConsumerStatefulWidget {
  const AiConfigPage({super.key});

  @override
  ConsumerState<AiConfigPage> createState() => _AiConfigPageState();
}

class _AiConfigPageState extends ConsumerState<AiConfigPage> {
  final TextEditingController _keyController = TextEditingController();
  bool _obscure = true;
  bool _testing = false;
  String? _message;
  bool _verified = false;
  bool _analysisConsent = false;
  bool _imageConsent = false;
  String _masked = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final masked = await ref.read(aiKeyStoreProvider).maskedKey();
    if (!mounted) {
      return;
    }
    setState(() {
      _verified = prefs.getBool(AiPrefsKeys.keyVerified) ?? false;
      _analysisConsent = prefs.getBool(AiPrefsKeys.analysisConsented) ?? false;
      _imageConsent = prefs.getBool(AiPrefsKeys.imageConsentAccepted) ?? false;
      _masked = masked;
    });
  }

  Future<void> _saveKey() async {
    final key = _keyController.text.trim();
    if (key.isEmpty) {
      setState(() => _message = '请输入 API Key');
      return;
    }
    try {
      await ref.read(aiKeyStoreProvider).saveKey(key);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AiPrefsKeys.keyVerified, false);
      _keyController.clear();
      await _load();
      if (mounted) {
        setState(() => _message = '已保存到系统安全存储，请测试连接');
      }
    } catch (error) {
      if (mounted) {
        setState(() => _message = '保存失败：$error');
      }
    }
  }

  Future<void> _test() async {
    setState(() {
      _testing = true;
      _message = null;
    });
    try {
      final result = await ref.read(aiClientProvider).testConnection();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(
        AiPrefsKeys.keyVerified,
        result == ConnectionResult.success,
      );
      if (mounted) {
        setState(() {
          _verified = result == ConnectionResult.success;
          _message = switch (result) {
            ConnectionResult.success => '连接成功，AI 功能已启用',
            ConnectionResult.invalidKeyOrQuota => 'Key 无效或额度不足，请检查后重试',
            ConnectionResult.networkError => '网络异常，请稍后重试',
          };
        });
        ref.invalidate(aiAvailabilityProvider);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _message = '测试失败：$error');
      }
    } finally {
      if (mounted) {
        setState(() => _testing = false);
      }
    }
  }

  Future<void> _deleteKey() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除 API Key'),
        content: const Text('删除后所有 AI 功能将不可用，确定继续吗？'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    await ref.read(aiKeyStoreProvider).deleteKey();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AiPrefsKeys.keyVerified, false);
    await _load();
    ref.invalidate(aiAvailabilityProvider);
  }

  Future<void> _setConsent(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    if (mounted) {
      setState(() {
        if (key == AiPrefsKeys.analysisConsented) {
          _analysisConsent = value;
        } else {
          _imageConsent = value;
        }
      });
    }
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI 接口配置')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '本 App 采用 BYOK（自带 Key）模式。Key 仅保存在系统安全存储中，'
                '不会上传到任何第三方服务器；只有你主动使用 AI 功能时，'
                '脱敏后的数据才会发送到你配置的模型服务。',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _keyController,
            obscureText: _obscure,
            decoration: InputDecoration(
              labelText: 'API Key',
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (_masked.isNotEmpty)
            Text(
              '当前 Key：$_masked',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          Row(
            children: <Widget>[
              Expanded(
                child: FilledButton(
                  onPressed: _saveKey,
                  child: const Text('保存 Key'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _testing ? null : _test,
            child: Text(_testing ? '测试中...' : '测试连接'),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Icon(
                _verified ? Icons.check_circle : Icons.info_outline,
                color: _verified ? AppColors.primary : AppColors.textSecondary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                _verified ? '已验证可用' : '尚未验证',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          if (_message != null) ...<Widget>[
            const SizedBox(height: 12),
            Text(_message!, style: const TextStyle(color: AppColors.danger)),
          ],
          const SizedBox(height: 20),
          SwitchListTile(
            title: const Text('允许 AI 收支分析'),
            subtitle: const Text('仅发送本地聚合统计，AI 只生成点评文案'),
            value: _analysisConsent,
            onChanged: (value) => _setConsent(AiPrefsKeys.analysisConsented, value),
          ),
          SwitchListTile(
            title: const Text('允许 AI 识别小票'),
            subtitle: const Text('图片上传前会二次确认，识别结果需人工审核'),
            value: _imageConsent,
            onChanged: (value) => _setConsent(AiPrefsKeys.imageConsentAccepted, value),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _deleteKey,
            icon: const Icon(Icons.delete_outline),
            label: const Text('删除已保存的 Key'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
