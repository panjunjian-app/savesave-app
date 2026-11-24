import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../state/providers.dart';

class LedgerFormPage extends ConsumerStatefulWidget {
  const LedgerFormPage({super.key});

  @override
  ConsumerState<LedgerFormPage> createState() => _LedgerFormPageState();
}

class _LedgerFormPageState extends ConsumerState<LedgerFormPage> {
  final TextEditingController _nameController = TextEditingController();
  String _icon = '📒';
  Color _color = AppColors.primary;
  bool _saving = false;
  String? _error;

  static const List<String> _icons = <String>['📒', '🏦', '💳', '🧾', '👛', '📱'];
  static const List<Color> _colors = <Color>[
    AppColors.primary,
    AppColors.gold,
    AppColors.danger,
    Color(0xFF4C9C86),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      setState(() => _error = '请先登录');
      return;
    }
    if (_nameController.text.trim().isEmpty) {
      setState(() => _error = '请输入账本名称');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final ledger = await ref.read(ledgerServiceProvider).createLedger(
            userId: user.id,
            name: _nameController.text,
            icon: _icon,
            color: '#${_color.value.toRadixString(16).substring(2).toUpperCase()}',
          );
      ref.read(selectedLedgerIdProvider.notifier).state = ledger.id;
      if (mounted) {
        context.go('/ledgers');
      }
    } catch (error) {
      if (mounted) {
        setState(() => _error = error.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('新建账本')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: '账本名称'),
          ),
          const SizedBox(height: 20),
          const Text('选择图标', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _icons
                .map(
                  (icon) => ChoiceChip(
                    label: Text(icon, style: const TextStyle(fontSize: 20)),
                    selected: _icon == icon,
                    onSelected: (_) => setState(() => _icon = icon),
                  ),
                )
                .toList(growable: false),
          ),
          const SizedBox(height: 20),
          const Text('主题色', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            children: _colors
                .map(
                  (color) => GestureDetector(
                    onTap: () => setState(() => _color = color),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _color == color ? AppColors.gold : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
          if (_error != null) ...<Widget>[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: AppColors.danger)),
          ],
          const SizedBox(height: 32),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? '创建中...' : '创建账本'),
          ),
        ],
      ),
    );
  }
}
