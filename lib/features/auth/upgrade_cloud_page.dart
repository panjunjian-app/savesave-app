import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../domain/models/user.dart';
import '../../domain/services/auth_service.dart';
import '../../state/providers.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text('升级为云端账号')),
      body: SafeArea(
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
              TextField(
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
              ),
              const SizedBox(height: 12),
              TextField(
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
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _busy ? null : _submit,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: _busy
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('开始升级'),
              ),
              if (_progress != null) ...<Widget>[
                const SizedBox(height: 12),
                Text(
                  _progress!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                  ),
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
              const SizedBox(height: 16),
              TextButton(
                onPressed: _busy
                    ? null
                    : () {
                        // 继续离线使用（C8 第二档），功能不受影响。
                        context.go('/home');
                      },
                child: const Text('暂不升级，继续离线使用'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
