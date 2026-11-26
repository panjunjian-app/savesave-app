import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/breakpoints.dart';
import '../../core/layout_tokens.dart';
import '../../core/theme.dart';
import '../../domain/models/user.dart';
import '../../domain/services/auth_service.dart';
import '../../state/providers.dart';
import '../common/app_buttons.dart';
import '../common/responsive_scaffold.dart';

/// 本机账号「升级为云端账号」引导页（PRD C8 三档策略 / 架构 §6.4）。
///
/// 流程：输入邮箱+密码 → 云端注册（邮箱已占用则转登录，云端数据按 LWW 合并）
/// → AccountMigrator 一次性迁移（重写归属 → 全量上传 → 校验）→ 进入同步模式。
/// 红线：迁移失败不删本机任何数据，可重试。
class UpgradeCloudPage extends ConsumerStatefulWidget {
  const UpgradeCloudPage({super.key});

  @override
  ConsumerState<UpgradeCloudPage> createState() => _UpgradeCloudPageState();
}

class _UpgradeCloudPageState extends ConsumerState<UpgradeCloudPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _busy = false;
  bool _obscurePassword = true;
  String? _error;
  String? _progress;

  static const List<String> _benefits = <String>[
    '手机、网页、平板使用同一账号查看相同数据',
    '本机历史数据一次性带上云端，一条不丢',
    '云端为权威副本，多端修改按较新记录保留',
    '迁移失败不删除本机数据，可随时重试',
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final emailError = AuthService.validateEmail(email);
    if (emailError != null) {
      setState(() => _error = emailError);
      return;
    }
    final passwordError = AuthService.validatePassword(password);
    if (passwordError != null) {
      setState(() => _error = passwordError);
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
      _progress = '正在创建/登录云端账号…';
    });
    try {
      final authService = ref.read(authServiceProvider);

      // 步骤 1：云端建号（已占用 → 合并模式登录）
      User user;
      try {
        user = await authService.signUpWithEmail(
          email: email,
          password: password,
        );
      } on AuthFailure catch (error) {
        if (error.message.contains('已注册')) {
          setState(() => _progress = '该邮箱已有云端账号，将按「较新记录保留」合并…');
          user = await authService.signInWithEmail(
            email: email,
            password: password,
          );
        } else {
          rethrow;
        }
      }
      ref.read(currentUserProvider.notifier).state = user;

      // 步骤 2：本机数据一次性迁移上云（可重试，失败不删本地）
      final migrator = ref.read(accountMigratorProvider);
      if (await migrator.needsMigration()) {
        setState(() => _progress = '正在把本机数据上传到云端…');
        final result = await migrator.migrate();
        if (!result.success && mounted) {
          setState(() {
            _busy = false;
            _progress = null;
            _error = result.message ?? '迁移未完成，请重试（本机数据未受影响）';
          });
          return;
        }
      }

      // 步骤 3：进入常规增量同步
      setState(() => _progress = '正在同步…');
      await ref.read(syncServiceProvider).syncNow();

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('升级完成，多端同步已开启')),
      );
      context.go('/home');
    } on AuthFailure catch (error) {
      if (mounted) {
        setState(() {
          _busy = false;
          _progress = null;
          _error = error.message;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _busy = false;
          _progress = null;
          _error = '操作失败，请稍后重试（本机数据未受影响）';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: '升级为云端账号',
      maxWidth: AppLayout.readerMaxWidth,
      backLocation: '/login',
      body: context.isCompact ? _buildCompactBody() : _buildDesktopBody(),
    );
  }

  /// 手机端：与改造前逐字一致的单列表单。
  Widget _buildCompactBody() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Icon(
              Icons.cloud_upload_outlined,
              size: 72,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              '把本机数据带入云端',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              '升级后可在手机与网页端使用同一账号查看相同数据。\n'
              '迁移过程中本机数据只写入不删除，失败可随时重试。',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 28),
            _buildEmailField(),
            const SizedBox(height: 12),
            _buildPasswordField(),
            const SizedBox(height: 20),
            _buildSubmitButton(),
            ..._buildProgressAndError(),
            const SizedBox(height: 16),
            _buildSkipButton(centered: false),
          ],
        ),
      ),
    );
  }

  /// 桌面端：880 居中，左 4 条权益（金色勾）｜右价格卡 + CTA 240。
  Widget _buildDesktopBody() {
    return ListView(
      padding: context.pagePadding,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Icon(
                    Icons.cloud_upload_outlined,
                    size: 56,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '把本机数据带入云端',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '升级后可在手机与网页端使用同一账号查看相同数据。',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                  for (final String benefit in _benefits)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: <Widget>[
                          const Icon(
                            Icons.check_circle,
                            size: 18,
                            color: AppColors.gold,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              benefit,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppLayout.sectionGap),
            SizedBox(
              width: 320,
              child: Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const Text(
                        '云端账号',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '多端同步 · 数据只属于你',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildEmailField(),
                      const SizedBox(height: 12),
                      _buildPasswordField(),
                      const SizedBox(height: 20),
                      Center(
                        child: SizedBox(
                          width: AppLayout.buttonMaxWidth,
                          child: _buildSubmitButton(),
                        ),
                      ),
                      ..._buildProgressAndError(),
                      const SizedBox(height: 12),
                      _buildSkipButton(centered: true),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppLayout.sectionGap),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      autofillHints: const <String>[AutofillHints.email],
      enabled: !_busy,
      decoration: const InputDecoration(
        labelText: '邮箱',
        hintText: 'you@example.com',
        prefixIcon: Icon(Icons.mail_outline),
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      autofillHints: const <String>[AutofillHints.newPassword],
      enabled: !_busy,
      onSubmitted: (_) => _submit(),
      decoration: InputDecoration(
        labelText: '设置云端密码',
        hintText: '至少 8 位',
        prefixIcon: const Icon(Icons.lock_outline),
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
          onPressed: () =>
              setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return AppButton.primary(
      label: '开始升级',
      busy: _busy,
      onPressed: _busy ? null : _submit,
    );
  }

  List<Widget> _buildProgressAndError() {
    return <Widget>[
      if (_progress != null) ...<Widget>[
        const SizedBox(height: 12),
        Text(
          _progress!,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.primary, fontSize: 13),
        ),
      ],
      if (_error != null) ...<Widget>[
        const SizedBox(height: 12),
        Text(
          _error!,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.danger, fontSize: 13),
        ),
      ],
    ];
  }

  Widget _buildSkipButton({required bool centered}) {
    final Widget button = AppButton.text(
      label: '暂不升级，继续离线使用',
      onPressed: _busy
          ? null
          : () {
              // 继续离线使用（C8 第二档），功能不受影响。
              context.go('/home');
            },
    );
    return centered ? Center(child: button) : button;
  }
}
