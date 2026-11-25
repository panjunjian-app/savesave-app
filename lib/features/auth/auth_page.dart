import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../domain/models/user.dart';
import '../../domain/services/auth_service.dart';
import '../../state/providers.dart';

enum _AuthMode { signIn, signUp }

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nicknameController = TextEditingController();

  _AuthMode _mode = _AuthMode.signIn;
  bool _agreed = false;
  bool _restoring = true;
  bool _busy = false;
  bool _obscurePassword = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _restore();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _restore() async {
    final service = ref.read(authServiceProvider);
    try {
      final user = await service.restoreLocalUser();
      if (!mounted) {
        return;
      }
      if (user != null) {
        ref.read(currentUserProvider.notifier).state = user;
        context.go('/home');
        return;
      }
    } catch (_) {
      // Restore is best effort: stay on the login page and allow retry.
    } finally {
      if (mounted) {
        setState(() => _restoring = false);
      }
    }
  }

  Future<void> _submit() async {
    if (!_agreed) {
      setState(() => _error = '请先阅读并同意用户协议与隐私政策');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final service = ref.read(authServiceProvider);
      final User user = _mode == _AuthMode.signUp
          ? await service.signUpWithEmail(
              email: _emailController.text,
              password: _passwordController.text,
              nickname: _nicknameController.text,
            )
          : await service.signInWithEmail(
              email: _emailController.text,
              password: _passwordController.text,
            );
      if (!mounted) {
        return;
      }
      ref.read(currentUserProvider.notifier).state = user;
      // 登录成功后：本机旧数据一次性迁移上云（可重试），随后增量同步。
      // 不阻塞进入首页，失败由设置页可重试/手动同步。
      unawaited(_postLoginSync());
      context.go('/home');
    } on AuthFailure catch (error) {
      if (mounted) {
        setState(() => _error = error.message);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = '操作失败，请稍后重试');
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  /// 登录后的迁移与首拉（架构 §6.4）：游客/本机旧账号数据升级上云 + 首拉。
  Future<void> _postLoginSync() async {
    try {
      final migrator = ref.read(accountMigratorProvider);
      if (await migrator.needsMigration()) {
        await migrator.migrate();
      }
      await ref.read(syncServiceProvider).syncNow();
    } catch (_) {
      // 迁移/同步失败不阻塞使用：设置页「立即同步」可重试。
    }
  }

  Future<void> _signInAsGuest() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final user = await ref.read(authServiceProvider).signInAsGuest();
      if (!mounted) {
        return;
      }
      ref.read(currentUserProvider.notifier).state = user;
      context.go('/home');
    } catch (_) {
      if (mounted) {
        setState(() => _error = '进入失败，请稍后重试');
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  void _switchMode(_AuthMode mode) {
    setState(() {
      _mode = mode;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _restoring
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.vertical,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const Icon(
                        Icons.savings_outlined,
                        size: 88,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '省省钱，存存钱',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '记好每一笔，存下每一个目标',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 32),
                      _buildModeTabs(),
                      const SizedBox(height: 20),
                      _buildEmailField(),
                      const SizedBox(height: 12),
                      _buildPasswordField(),
                      if (_mode == _AuthMode.signUp) ...<Widget>[
                        const SizedBox(height: 12),
                        _buildNicknameField(),
                      ],
                      const SizedBox(height: 20),
                      _buildSubmitButton(),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _busy ? null : _signInAsGuest,
                        icon: const Icon(Icons.person_outline),
                        label: const Text('暂不注册，以游客模式体验'),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _busy
                            ? null
                            : () => context.go('/upgrade-cloud'),
                        child: const Text(
                          '已有本机数据？升级为云端账号，开启多端同步',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_error != null) ...<Widget>[
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.danger,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      _buildAgreementRow(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildModeTabs() {
    return SegmentedButton<_AuthMode>(
      segments: const <ButtonSegment<_AuthMode>>[
        ButtonSegment<_AuthMode>(
          value: _AuthMode.signIn,
          label: Text('登录'),
          icon: Icon(Icons.login),
        ),
        ButtonSegment<_AuthMode>(
          value: _AuthMode.signUp,
          label: Text('注册'),
          icon: Icon(Icons.person_add_alt),
        ),
      ],
      selected: {_mode},
      onSelectionChanged: (Set<_AuthMode> selection) =>
          _switchMode(selection.first),
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
      autofillHints: const <String>[AutofillHints.password],
      enabled: !_busy,
      onSubmitted: (_) => _submit(),
      decoration: InputDecoration(
        labelText: '密码',
        hintText: _mode == _AuthMode.signUp ? '至少 8 位' : null,
        prefixIcon: const Icon(Icons.lock_outline),
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          ),
          onPressed: () =>
              setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
    );
  }

  Widget _buildNicknameField() {
    return TextField(
      controller: _nicknameController,
      enabled: !_busy,
      maxLength: 20,
      decoration: const InputDecoration(
        labelText: '昵称（可选）',
        hintText: '怎么称呼你？',
        prefixIcon: Icon(Icons.badge_outlined),
        border: OutlineInputBorder(),
        counterText: '',
      ),
    );
  }

  Widget _buildSubmitButton() {
    return FilledButton(
      onPressed: _busy ? null : _submit,
      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
      child: _busy
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(_mode == _AuthMode.signUp ? '注册并进入' : '登录'),
    );
  }

  Widget _buildAgreementRow() {
    return Row(
      children: <Widget>[
        Checkbox(
          value: _agreed,
          onChanged: _busy
              ? null
              : (bool? value) => setState(() => _agreed = value ?? false),
        ),
        const Expanded(
          child: Text(
            '我已阅读并同意《用户协议》与《隐私政策》\n账号数据仅保存在本机，AI 功能需自行配置 Key',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}
