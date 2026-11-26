import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/breakpoints.dart';
import '../../core/layout_tokens.dart';
import '../../core/money.dart';
import '../../core/theme.dart';
import '../../domain/models/ledger.dart';
import '../../domain/models/savings_goal.dart';
import '../../state/providers.dart';
import '../common/amount_field.dart';
import '../common/app_buttons.dart';
import '../common/form_field_row.dart';
import '../common/responsive_scaffold.dart';

const List<String> _goalIcons = <String>['🏠', '🚗', '🎓', '💍', '✈️', '🎁', '📱', '💡'];
const List<Color> _goalColors = <Color>[
  AppColors.primary,
  AppColors.gold,
  AppColors.danger,
  Color(0xFF4C9C86),
  Color(0xFF6B7772),
];

class GoalFormPage extends ConsumerStatefulWidget {
  const GoalFormPage({super.key, this.goalId});

  final String? goalId;

  @override
  ConsumerState<GoalFormPage> createState() => _GoalFormPageState();
}

class _GoalFormPageState extends ConsumerState<GoalFormPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String? _deadline;
  int? _targetCents;
  String _icon = '🏠';
  Color _color = AppColors.primary;
  final Set<String> _selectedLedgers = <String>{};
  SavingsGoal? _goal;
  bool _loaded = false;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = widget.goalId;
    if (id != null) {
      _goal = await ref.read(goalDaoProvider).findById(id);
      _selectedLedgers.addAll(await ref.read(goalDaoProvider).boundLedgerIds(id));
      if (_goal != null) {
        _nameController.text = _goal!.name;
        _noteController.text = _goal!.note ?? '';
        _deadline = _goal!.deadline;
        _targetCents = _goal!.targetAmountCents;
        _icon = _goal!.icon.isEmpty ? _icon : _goal!.icon;
        _color = _colorFromHex(_goal!.themeColor);
      }
    }
    if (mounted) {
      setState(() => _loaded = true);
    }
  }

  Color _colorFromHex(String hex) {
    final value = int.tryParse(hex.replaceAll('#', ''), radix: 16);
    if (value == null) {
      return AppColors.primary;
    }
    return Color(value | 0xFF000000);
  }

  Future<void> _pickDeadline() async {
    final initial = DateTime.tryParse(_deadline ?? '') ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 20)),
    );
    if (picked != null) {
      setState(() {
        _deadline = picked.toIso8601String().substring(0, 10);
      });
    }
  }

  Future<void> _save() async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      setState(() => _error = '请先登录');
      return;
    }
    if (_targetCents == null) {
      setState(() => _error = '请输入目标金额');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final service = ref.read(goalServiceProvider);
      final hex = '#${_color.value.toRadixString(16).substring(2).toUpperCase()}';
      if (_goal == null) {
        await service.createGoal(
          userId: user.id,
          name: _nameController.text,
          targetAmountCents: _targetCents!,
          deadline: _deadline,
          icon: _icon,
          themeColor: hex,
          note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
          ledgerIds: _selectedLedgers,
        );
      } else {
        await service.updateGoal(
          goal: _goal!,
          name: _nameController.text,
          targetAmountCents: _targetCents!,
          deadline: _deadline,
          icon: _icon,
          themeColor: hex,
          note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
          ledgerIds: _selectedLedgers,
        );
      }
      if (mounted) {
        context.go(widget.goalId == null ? '/home' : '/goals/${widget.goalId}');
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
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ledgersAsync = ref.watch(ledgersProvider);
    final editing = widget.goalId != null;
    final compact = context.isCompact;

    return ResponsiveScaffold(
      title: editing ? '编辑目标' : '新建目标',
      maxWidth: compact ? AppLayout.contentMaxWidth : AppLayout.formTwoColumnMaxWidth,
      backLocation: editing ? '/goals/${widget.goalId}' : '/home',
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : compact
              ? _buildCompactForm(ledgersAsync)
              : _buildDesktopForm(ledgersAsync),
    );
  }

  /// 手机端表单：字段顺序 / 间距与改造前完全一致。
  Widget _buildCompactForm(AsyncValue<List<Ledger>> ledgersAsync) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: '目标名称'),
        ),
        const SizedBox(height: 16),
        AmountField(
          initialCents: _targetCents ?? 0,
          onCentsChanged: (cents) => setState(() => _targetCents = cents),
        ),
        const SizedBox(height: 16),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('截止日期'),
          subtitle: Text(_deadline ?? '未设置'),
          trailing: const Icon(Icons.calendar_today_outlined),
          onTap: _pickDeadline,
        ),
        const SizedBox(height: 8),
        const Text('选择图标', style: TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _goalIcons.map((icon) {
            return ChoiceChip(
              label: Text(icon, style: const TextStyle(fontSize: 20)),
              selected: _icon == icon,
              onSelected: (_) => setState(() => _icon = icon),
            );
          }).toList(growable: false),
        ),
        const SizedBox(height: 16),
        const Text('主题色', style: TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        _colorPicker(),
        const SizedBox(height: 20),
        const Text(
          '绑定账本（可多选，结余自动累计）',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        _ledgerCheckboxes(ledgersAsync),
        const SizedBox(height: 16),
        TextField(
          controller: _noteController,
          maxLines: 3,
          decoration: const InputDecoration(labelText: '备注（可选）'),
        ),
        if (_error != null) ...<Widget>[
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: AppColors.danger)),
        ],
        const SizedBox(height: 28),
        AppButton.primary(
          label: _saving ? '保存中...' : '保存目标',
          onPressed: _saving ? null : _save,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  /// 桌面端表单：两列 2×480（左：名称 / 金额 / 截止日；右：绑定账本 / 备注 / 实时提示）。
  Widget _buildDesktopForm(AsyncValue<List<Ledger>> ledgersAsync) {
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
                  FormRow(
                    label: '目标名称',
                    child: TextField(
                      controller: _nameController,
                      decoration: AppInput.decoration(
                        context,
                        label: '目标名称',
                        hint: '例如：旅行基金',
                      ),
                    ),
                  ),
                  FormRow(
                    label: '目标金额',
                    child: AmountField(
                      initialCents: _targetCents ?? 0,
                      fontSize: 30,
                      onCentsChanged: (cents) =>
                          setState(() => _targetCents = cents),
                    ),
                  ),
                  FormRow(
                    label: '截止日期',
                    child: InkWell(
                      onTap: _pickDeadline,
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: AppInput.decoration(context, label: '截止日期'),
                        child: Row(
                          children: <Widget>[
                            Expanded(child: Text(_deadline ?? '未设置')),
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppLayout.blockGap),
                  const Text(
                    '选择图标',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _goalIcons.map((icon) {
                      return ChoiceChip(
                        label: Text(icon, style: const TextStyle(fontSize: 20)),
                        selected: _icon == icon,
                        onSelected: (_) => setState(() => _icon = icon),
                      );
                    }).toList(growable: false),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '主题色',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  _colorPicker(),
                ],
              ),
            ),
            const SizedBox(width: AppLayout.sectionGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    '绑定账本（可多选，结余自动累计）',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    margin: EdgeInsets.zero,
                    child: _ledgerCheckboxes(ledgersAsync),
                  ),
                  const SizedBox(height: AppLayout.blockGap),
                  FormRow(
                    label: '备注',
                    child: TextField(
                      controller: _noteController,
                      maxLines: 3,
                      decoration: AppInput.decoration(context, label: '备注（可选）'),
                    ),
                  ),
                  const SizedBox(height: AppLayout.blockGap),
                  _savingsHint(),
                ],
              ),
            ),
          ],
        ),
        if (_error != null) ...<Widget>[
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: AppColors.danger)),
        ],
        const SizedBox(height: AppLayout.sectionGap),
        FormActionBar(
          secondary: AppButton.text(
            label: '取消',
            onPressed: () => context.go(
              widget.goalId == null ? '/home' : '/goals/${widget.goalId}',
            ),
          ),
          primary: AppButton.primary(
            label: _saving ? '保存中...' : '保存目标',
            busy: _saving,
            onPressed: _save,
          ),
        ),
        const SizedBox(height: AppLayout.sectionGap),
      ],
    );
  }

  Widget _colorPicker() {
    return Wrap(
      spacing: 12,
      children: _goalColors.map((color) {
        return GestureDetector(
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
        );
      }).toList(growable: false),
    );
  }

  Widget _ledgerCheckboxes(AsyncValue<List<Ledger>> ledgersAsync) {
    return ledgersAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text('加载账本失败：$error'),
      ),
      data: (ledgers) {
        if (ledgers.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('暂无账本，请先创建账本'),
          );
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: ledgers.map((ledger) {
            return CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('${ledger.icon} ${ledger.name}'),
              value: _selectedLedgers.contains(ledger.id),
              onChanged: (checked) => setState(() {
                if (checked ?? false) {
                  _selectedLedgers.add(ledger.id);
                } else {
                  _selectedLedgers.remove(ledger.id);
                }
              }),
            );
          }).toList(growable: false),
        );
      },
    );
  }

  /// 桌面端实时提示：已绑定 N 个账本 · 预计每月需存 X（PRD §5 第 9 页）。
  Widget _savingsHint() {
    final int target = _targetCents ?? 0;
    String perMonth = '—';
    if (target > 0) {
      final deadline = DateTime.tryParse(_deadline ?? '');
      int months = 12;
      if (deadline != null) {
        final now = DateTime.now();
        months = (deadline.year - now.year) * 12 + (deadline.month - now.month);
        if (months < 1) {
          months = 1;
        }
      }
      perMonth = Money.formatCents((target / months).round());
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.goldLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '已绑定 ${_selectedLedgers.length} 个账本 · 预计每月需存 $perMonth',
        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
      ),
    );
  }
}
