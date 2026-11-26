import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/breakpoints.dart';
import '../../core/layout_tokens.dart';
import '../../core/theme.dart';
import '../../data/services/ai_client.dart';
import '../../state/providers.dart';
import '../common/app_buttons.dart';
import '../common/responsive_scaffold.dart';

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
        setState(() {
          _verified = false;
          _testing = false;
          _message = reason;
        });
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
    return ResponsiveScaffold(
      title: 'AI 接口配置',
      maxWidth: AppLayout.formTwoColumnMaxWidth,
      backLocation: '/settings',
      body: context.isCompact ? _buildCompactBody() : _buildDesktopBody(),
    );
  }

  /// 手机端：与改造前逐字一致的列表结构。
  Widget _buildCompactBody() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        _introCard(),
        const SizedBox(height: 12),
        _keyField(),
        const SizedBox(height: 12),
        if (_masked.isNotEmpty)
          Text(
            '当前 Key：$_masked',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        Row(
          children: <Widget>[
            Expanded(
              child: AppButton.primary(label: '保存 Key', onPressed: _saveKey),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AppButton.secondary(
          label: _testing
              ? (_retryCountdown > 0
                  ? '自动重试中…（第 $_retryRound/10 次，$_retryCountdown 秒后重试）'
                  : '测试中…（第 $_retryRound/10 次）')
              : '测试连接',
          onPressed: _testing ? null : _test,
        ),
        if (_testing && _retryCountdown > 0)
          AppButton.text(
            label: '停止自动重试',
            onPressed: () => setState(() {
              _retryCancelled = true;
              _testing = false;
              _retryCountdown = 0;
              _message = '已停止自动重试';
            }),
          ),
        const SizedBox(height: 8),
        _statusRow(),
        if (_message != null) ...<Widget>[
          const SizedBox(height: 12),
          Text(_message!, style: const TextStyle(color: AppColors.danger)),
        ],
        const SizedBox(height: 20),
        _analysisSwitch(),
        _imageSwitch(),
        const SizedBox(height: 16),
        AppButton.secondary(
          label: '删除已保存的 Key',
          icon: Icons.delete_outline,
          onPressed: _deleteKey,
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  /// 桌面端：左 480（Key + 并排两按钮 + 掩码 + 状态 + 固定高度倒计时）｜右 480（授权 + 安全说明）。
  Widget _buildDesktopBody() {
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
                  _introCard(),
                  const SizedBox(height: AppLayout.cardGap),
                  _keyField(),
                  const SizedBox(height: 12),
                  Text(
                    _masked.isEmpty ? '当前未保存 Key' : '当前 Key：$_masked',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: AppButton.primary(
                          label: '保存 Key',
                          onPressed: _saveKey,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton.secondary(
                          label: '测试连接',
                          onPressed: _testing ? null : _test,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 倒计时区固定高度，避免文本变化导致布局跳动（C3）。
                  SizedBox(
                    height: 24,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _testing
                            ? (_retryCountdown > 0
                                ? '第 $_retryRound/10 次，$_retryCountdown 秒后重试'
                                : '第 $_retryRound/10 次')
                            : '',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  if (_testing && _retryCountdown > 0)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: AppButton.text(
                        label: '停止自动重试',
                        onPressed: () => setState(() {
                          _retryCancelled = true;
                          _testing = false;
                          _retryCountdown = 0;
                          _message = '已停止自动重试';
                        }),
                      ),
                    ),
                  const SizedBox(height: 8),
                  _statusRow(),
                  if (_message != null) ...<Widget>[
                    const SizedBox(height: 12),
                    Text(
                      _message!,
                      style: const TextStyle(color: AppColors.danger),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AppButton.secondary(
                      label: '删除已保存的 Key',
                      icon: Icons.delete_outline,
                      onPressed: _deleteKey,
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
                  Card(
                    margin: EdgeInsets.zero,
                    child: Column(
                      children: <Widget>[_analysisSwitch(), _imageSwitch()],
                    ),
                  ),
                  const SizedBox(height: AppLayout.cardGap),
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '安全说明',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '· Key 仅保存在系统安全存储，不上传任何第三方服务器\n'
                            '· 只有你主动使用 AI 功能时，脱敏后的数据才会发送到所配置的模型服务\n'
                            '· 可随时删除 Key，删除后所有 AI 功能立即不可用',
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.7,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppLayout.sectionGap),
      ],
    );
  }

  Widget _introCard() {
    return const Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          '本 App 采用 BYOK（自带 Key）模式。Key 仅保存在系统安全存储中，'
          '不会上传到任何第三方服务器；只有你主动使用 AI 功能时，'
          '脱敏后的数据才会发送到你配置的模型服务。',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      ),
    );
  }

  Widget _keyField() {
    return TextField(
      controller: _keyController,
      obscureText: _obscure,
      decoration: InputDecoration(
        labelText: 'API Key',
        suffixIcon: IconButton(
          icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
    );
  }

  Widget _statusRow() {
    return Row(
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
    );
  }

  Widget _analysisSwitch() {
    return SwitchListTile(
      title: const Text('允许 AI 收支分析'),
      subtitle: const Text('仅发送本地聚合统计，AI 只生成点评文案'),
      value: _analysisConsent,
      onChanged: (value) => _setConsent(AiPrefsKeys.analysisConsented, value),
    );
  }

  Widget _imageSwitch() {
    return SwitchListTile(
      title: const Text('允许 AI 识别小票'),
      subtitle: const Text('图片上传前会二次确认，识别结果需人工审核'),
      value: _imageConsent,
      onChanged: (value) => _setConsent(AiPrefsKeys.imageConsentAccepted, value),
    );
  }
}
