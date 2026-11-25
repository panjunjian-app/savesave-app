import 'dart:async';

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

  /// 自动重试状态：当前第几次尝试、倒计时剩余秒数、取消用的定时器。
  int _retryRound = 0;
  int _retryCountdown = 0;
  Timer? _retryTimer;

  /// 用户点「停止自动重试」后置 true，循环据此退出。
  bool _retryCancelled = false;

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

  /// 测试连接：遇到限流（1302/1305/1308/1310）或网络抖动时**自动重试**，
  /// 间隔 1 分钟，最多 10 次；10 次都失败才把错误展示给用户。
  ///
  /// Key 无效（1001-1005）、账户欠费（1113）这类重试无意义的原因不重试，
  /// 直接给出具体原因与处理建议。
  Future<void> _test() async {
    _retryTimer?.cancel();
    setState(() {
      _testing = true;
      _message = null;
      _retryRound = 0;
      _retryCountdown = 0;
      _retryCancelled = false;
    });

    const maxAttempts = 10;
    const retryDelay = Duration(minutes: 1);

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      if (!mounted || _retryCancelled) {
        return;
      }
      setState(() {
        _retryRound = attempt;
        _retryCountdown = 0;
      });

      ConnectionProbe probe;
      try {
        probe = await ref.read(aiClientProvider).testConnection();
      } catch (error) {
        probe = ConnectionProbe(ConnectionResult.networkError, '测试失败：$error', true);
      }
      if (!mounted) {
        return;
      }

      if (probe.ok) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(AiPrefsKeys.keyVerified, true);
        if (!mounted) {
          return;
        }
        setState(() {
          _verified = true;
          _testing = false;
          _message = attempt == 1
              ? '连接成功，AI 功能已启用'
              : '连接成功（第 $attempt 次尝试），AI 功能已启用';
        });
        ref.invalidate(aiAvailabilityProvider);
        return;
      }

      final detail = probe.detail ?? '连接失败，请稍后重试';
      final canRetry = probe.retryable && attempt < maxAttempts;
      if (!canRetry) {
        final reason = probe.retryable
            ? '$detail（已自动重试 $maxAttempts 次仍未成功）'
            : detail;
        if (attempt > 1 || probe.retryable) {
          // 记录重试过程，便于用户知道系统确实努力过
          setState(() {
            _verified = false;
            _testing = false;
            _message = reason;
          });
        } else {
          setState(() {
            _verified = false;
            _testing = false;
            _message = reason;
          });
        }
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(AiPrefsKeys.keyVerified, false);
        ref.invalidate(aiAvailabilityProvider);
        return;
      }

      // 进入倒计时等待，期间可被「取消」中断
      for (var remaining = retryDelay.inSeconds; remaining > 0; remaining--) {
        if (!mounted || _retryCancelled) {
          return;
        }
        setState(() {
          _retryCountdown = remaining;
          _message = '$detail\n将于 $remaining 秒后自动重试'
              '（第 ${attempt + 1}/$maxAttempts 次）';
        });
        await Future<void>.delayed(const Duration(seconds: 1));
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
    _retryTimer?.cancel();
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
            child: Text(
              _testing
                  ? (_retryCountdown > 0
                      ? '自动重试中…（第 $_retryRound/10 次，$_retryCountdown 秒后重试）'
                      : '测试中…（第 $_retryRound/10 次）')
                  : '测试连接',
            ),
          ),
          if (_testing && _retryCountdown > 0)
            TextButton(
              onPressed: () => setState(() {
                _retryCancelled = true;
                _testing = false;
                _retryCountdown = 0;
                _message = '已停止自动重试';
              }),
              child: const Text('停止自动重试'),
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
