import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/breakpoints.dart';
import '../../core/layout_tokens.dart';
import '../../core/theme.dart';
import '../../state/providers.dart';
import '../common/app_buttons.dart';
import '../common/form_field_row.dart';
import '../common/responsive_scaffold.dart';

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

  /// 桌面端图标网格的固定列数（PRD §5 第 8 页）。
  static const int _desktopIconColumns = 8;

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
    return ResponsiveScaffold(
      title: '新建账本',
      maxWidth: AppLayout.formMaxWidth,
      backLocation: '/ledgers',
      body: context.isCompact ? _buildCompactForm() : _buildDesktopForm(),
    );
  }

  /// 手机端表单：字段顺序 / 间距与改造前完全一致。
  Widget _buildCompactForm() {
    return ListView(
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
        _colorPicker(),
        if (_error != null) ...<Widget>[
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: AppColors.danger)),
        ],
        const SizedBox(height: 32),
        AppButton.primary(
          label: _saving ? '创建中...' : '创建账本',
          onPressed: _saving ? null : _save,
        ),
      ],
    );
  }

  /// 桌面端表单：左标签右控件 + 8 列图标网格 + 保存右对齐。
  Widget _buildDesktopForm() {
    return ListView(
      padding: context.pagePadding,
      children: <Widget>[
        FormRow(
          label: '账本名称',
          child: TextField(
            controller: _nameController,
            decoration: AppInput.decoration(
              context,
              label: '账本名称',
              hint: '例如：日常开销',
            ),
          ),
        ),
        const SizedBox(height: AppLayout.blockGap),
        const Text(
          '选择图标',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        _iconGrid(),
        const SizedBox(height: AppLayout.sectionGap),
        const Text(
          '主题色',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        _colorPicker(),
        if (_error != null) ...<Widget>[
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: AppColors.danger)),
        ],
        const SizedBox(height: AppLayout.sectionGap),
        FormActionBar(
          secondary: AppButton.text(
            label: '取消',
            onPressed: () => context.go('/ledgers'),
          ),
          primary: AppButton.primary(
            label: _saving ? '创建中...' : '创建账本',
            onPressed: _saving ? null : _save,
          ),
        ),
        const SizedBox(height: AppLayout.sectionGap),
      ],
    );
  }

  /// 桌面端 8 列固定图标网格。
  Widget _iconGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double spacing = 8;
        final double itemWidth =
            (constraints.maxWidth - spacing * (_desktopIconColumns - 1)) /
                _desktopIconColumns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: _icons
              .map(
                (icon) => SizedBox(
                  width: itemWidth,
                  height: 52,
                  child: _IconTile(
                    icon: icon,
                    selected: _icon == icon,
                    onTap: () => setState(() => _icon = icon),
                  ),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }

  Widget _colorPicker() {
    return Wrap(
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
    );
  }
}

/// 桌面端图标块。
class _IconTile extends StatelessWidget {
  const _IconTile({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Text(icon, style: const TextStyle(fontSize: 20)),
      ),
    );
  }
}
