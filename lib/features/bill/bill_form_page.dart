import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/breakpoints.dart';
import '../../core/layout_tokens.dart';
import '../../core/theme.dart';
import '../../data/services/ai_client.dart';
import '../../domain/models/category.dart';
import '../../domain/models/ledger.dart';
import '../../state/providers.dart';
import '../common/amount_field.dart';
import '../common/app_buttons.dart';
import '../common/form_field_row.dart';
import '../common/responsive_scaffold.dart';

class BillFormPage extends ConsumerStatefulWidget {
  const BillFormPage({super.key});

  @override
  ConsumerState<BillFormPage> createState() => _BillFormPageState();
}

class _BillFormPageState extends ConsumerState<BillFormPage> {
  final TextEditingController _noteController = TextEditingController();
  int? _amountCents;
  String _type = 'expense';
  String? _categoryId;
  String? _ledgerId;
  String _billDate = DateTime.now().toIso8601String().substring(0, 10);
  bool _saving = false;
  bool _recognizing = false;
  XFile? _image;
  String? _error;
  CancelToken? _cancelToken;

  @override
  void initState() {
    super.initState();
    final selected = ref.read(selectedLedgerIdProvider);
    if (selected.isNotEmpty && selected != Ledger.allKey) {
      _ledgerId = selected;
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    _cancelToken?.cancel();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final initial = DateTime.tryParse(_billDate) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) {
      setState(() {
        _billDate = picked.toIso8601String().substring(0, 10);
      });
    }
  }

  Future<void> _recognizeFromImage() async {
    final available = await ref.read(aiAvailabilityProvider.future);
    if (!available) {
      _showMessage('请先在「设置 → AI 接口配置」中完成 Key 配置与验证');
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) {
      return;
    }
    if (prefs.getBool(AiPrefsKeys.imageConsentAccepted) != true) {
      final agreed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('使用 AI 识别小票'),
          content: const Text(
            '图片将上传到你自配置的 AI 服务用于字段提取。信息脱敏后传输，识别结果需要你确认后才会保存。是否继续？',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('同意并继续'),
            ),
          ],
        ),
      );
      if (agreed != true) {
        return;
      }
      await prefs.setBool(AiPrefsKeys.imageConsentAccepted, true);
    }

    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file == null) {
      return;
    }
    setState(() {
      _image = file;
      _recognizing = true;
      _error = null;
    });
    _cancelToken = CancelToken();
    try {
      final bytes = await File(file.path).readAsBytes();
      final draft = await ref.read(aiClientProvider).recognizeBill(
            bytes: bytes,
            token: _cancelToken!,
          );
      final categories = await ref.read(categoryDaoProvider).findAll();
      final ledgers = await ref.read(ledgerDaoProvider).findAll();
      if (!mounted) {
        return;
      }
      setState(() {
        if (draft.amountCents != null) {
          _amountCents = draft.amountCents;
        }
        if (draft.type == 'income' || draft.type == 'expense') {
          _type = draft.type!;
        }
        if (draft.category != null) {
          final match = categories.where((c) => c.name == draft.category).firstOrNull;
          if (match != null) {
            _categoryId = match.id;
          }
        }
        if (draft.ledger != null) {
          final match = ledgers.where((l) => l.name == draft.ledger).firstOrNull;
          if (match != null) {
            _ledgerId = match.id;
          }
        }
        if (draft.date != null && DateTime.tryParse(draft.date!) != null) {
          _billDate = draft.date!;
        }
        if (draft.note != null) {
          _noteController.text = draft.note!;
        }
      });
      _showMessage('识别完成，请核对后保存');
    } on AiCancelledException {
      _showMessage('已取消识别');
    } on AiFailure catch (failure) {
      setState(() => _error = failure.message);
    } catch (error) {
      setState(() => _error = '识别失败：$error');
    } finally {
      if (mounted) {
        setState(() => _recognizing = false);
      }
    }
  }

  Future<void> _save() async {
    if (_amountCents == null || _amountCents! <= 0) {
      setState(() => _error = '请输入有效金额');
      return;
    }
    if (_ledgerId == null) {
      setState(() => _error = '请选择账本');
      return;
    }
    if (_categoryId == null) {
      setState(() => _error = '请选择分类');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(billServiceProvider).quickAddBill(
            ledgerId: _ledgerId!,
            categoryId: _categoryId!,
            type: _type,
            amountCents: _amountCents!,
            billDate: _billDate,
            note: _noteController.text.trim().isEmpty
                ? null
                : _noteController.text.trim(),
            source: _image == null ? 'manual' : 'ai',
          );
      ref.read(dataRevisionProvider.notifier).state++;
      if (mounted) {
        context.go('/home');
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

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final ledgersAsync = ref.watch(ledgersProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final categories = (categoriesAsync.valueOrNull ?? const <Category>[])
        .where((category) => category.type == _type)
        .toList(growable: false);

    return ResponsiveScaffold(
      title: '记一笔',
      maxWidth: AppLayout.formMaxWidth,
      backLocation: '/bills',
      body: context.isCompact
          ? _buildCompactForm(ledgersAsync, categories)
          : _buildDesktopForm(ledgersAsync, categories),
    );
  }

  /// 手机端表单：字段顺序 / 间距与改造前完全一致。
  Widget _buildCompactForm(
    AsyncValue<List<Ledger>> ledgersAsync,
    List<Category> categories,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        _typeSelector(),
        const SizedBox(height: 16),
        AmountField(
          onCentsChanged: (cents) => setState(() => _amountCents = cents),
        ),
        const SizedBox(height: 16),
        _ledgerField(ledgersAsync),
        const SizedBox(height: 16),
        _categoryDropdown(categories),
        const SizedBox(height: 8),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('账单日期'),
          subtitle: Text(_billDate),
          trailing: const Icon(Icons.calendar_today_outlined),
          onTap: _pickDate,
        ),
        const SizedBox(height: 8),
        _noteField(),
        const SizedBox(height: 16),
        _aiRecognizeButton(),
        if (_image != null) _imageHint(),
        if (_error != null) ...<Widget>[
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: AppColors.danger)),
        ],
        const SizedBox(height: 24),
        AppButton.primary(
          label: _saving ? '保存中...' : '保存账单',
          onPressed: _saving ? null : _save,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  /// 桌面端表单：480 单列，金额置顶放大、分类图标网格、保存右对齐。
  Widget _buildDesktopForm(
    AsyncValue<List<Ledger>> ledgersAsync,
    List<Category> categories,
  ) {
    return ListView(
      padding: context.pagePadding,
      children: <Widget>[
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  '金额',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                AmountField(
                  fontSize: 32,
                  onCentsChanged: (cents) =>
                      setState(() => _amountCents = cents),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppLayout.sectionGap),
        _typeSelector(),
        const SizedBox(height: AppLayout.sectionGap),
        FormRow(label: '账本', child: _ledgerField(ledgersAsync)),
        FormRow(label: '日期', child: _dateFieldWithShortcuts()),
        const SizedBox(height: AppLayout.blockGap),
        const Text(
          '分类',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        _categoryGrid(categories),
        const SizedBox(height: AppLayout.sectionGap),
        FormRow(label: '备注', child: _noteField()),
        const SizedBox(height: AppLayout.blockGap),
        // 桌面档按钮必须收敛到 <=240（ListView 会给子项 tight 宽度，需 Align 松开）。
        Align(alignment: Alignment.centerLeft, child: _aiRecognizeButton()),
        if (_image != null) _imageHint(),
        if (_error != null) ...<Widget>[
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: AppColors.danger)),
        ],
        const SizedBox(height: AppLayout.sectionGap),
        FormActionBar(
          secondary: AppButton.text(
            label: '取消',
            onPressed: () => context.go('/bills'),
          ),
          primary: AppButton.primary(
            label: _saving ? '保存中...' : '保存账单',
            busy: _saving,
            onPressed: _save,
          ),
        ),
        const SizedBox(height: AppLayout.sectionGap),
      ],
    );
  }

  Widget _typeSelector() {
    return SegmentedButton<String>(
      segments: const <ButtonSegment<String>>[
        ButtonSegment<String>(value: 'expense', label: Text('支出')),
        ButtonSegment<String>(value: 'income', label: Text('收入')),
      ],
      selected: <String>{_type},
      onSelectionChanged: (values) => setState(() {
        _type = values.first;
        _categoryId = null;
      }),
    );
  }

  Widget _ledgerField(AsyncValue<List<Ledger>> ledgersAsync) {
    return ledgersAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (error, _) => Text('账本加载失败：$error'),
      data: (ledgers) => DropdownButtonFormField<String>(
        initialValue: _ledgerId,
        decoration: AppInput.decoration(context, label: '账本'),
        items: ledgers
            .map(
              (ledger) => DropdownMenuItem<String>(
                value: ledger.id,
                child: Text('${ledger.icon} ${ledger.name}'),
              ),
            )
            .toList(growable: false),
        onChanged: (value) => setState(() => _ledgerId = value),
      ),
    );
  }

  Widget _categoryDropdown(List<Category> categories) {
    return DropdownButtonFormField<String>(
      initialValue: _categoryId,
      decoration: const InputDecoration(labelText: '分类'),
      items: categories
          .map(
            (category) => DropdownMenuItem<String>(
              value: category.id,
              child: Text('${category.icon} ${category.name}'),
            ),
          )
          .toList(growable: false),
      onChanged: (value) => setState(() => _categoryId = value),
    );
  }

  Widget _dateFieldWithShortcuts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        InkWell(
          onTap: _pickDate,
          borderRadius: BorderRadius.circular(12),
          child: InputDecorator(
            decoration: AppInput.decoration(context, label: '账单日期'),
            child: Row(
              children: <Widget>[
                Expanded(child: Text(_billDate)),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            _QuickDateChip(
              label: '今天',
              selected: _billDate == _isoDate(DateTime.now()),
              onTap: () => setState(() => _billDate = _isoDate(DateTime.now())),
            ),
            const SizedBox(width: 8),
            _QuickDateChip(
              label: '昨天',
              selected: _billDate ==
                  _isoDate(DateTime.now().subtract(const Duration(days: 1))),
              onTap: () => setState(
                () => _billDate =
                    _isoDate(DateTime.now().subtract(const Duration(days: 1))),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _noteField() {
    return TextField(
      controller: _noteController,
      maxLines: context.isCompact ? 2 : 3,
      decoration: AppInput.decoration(context, label: '备注（可选）'),
    );
  }

  /// 分类图标网格：每行 6 个（PRD §5 第 5 页）。
  Widget _categoryGrid(List<Category> categories) {
    if (categories.isEmpty) {
      return const Text('暂无分类');
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        const int columns = 6;
        const double spacing = 8;
        final double itemWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: categories
              .map(
                (category) => SizedBox(
                  width: itemWidth,
                  child: _CategoryTile(
                    category: category,
                    selected: _categoryId == category.id,
                    onTap: () => setState(() => _categoryId = category.id),
                  ),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }

  Widget _aiRecognizeButton() {
    return AppButton.secondary(
      label: _recognizing ? '识别中...' : '上传小票，AI 自动填入',
      icon: Icons.image_outlined,
      busy: _recognizing,
      onPressed: _recognizeFromImage,
    );
  }

  Widget _imageHint() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        '已选择图片：${_image!.name}（保存前请核对所有字段）',
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
    );
  }

  String _isoDate(DateTime date) {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${date.year}-${two(date.month)}-${two(date.day)}';
  }
}

/// 桌面端分类图标块（图标在上、名称在下）。
class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final Category category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(category.icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 2),
            Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: selected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 日期快捷选项（今天 / 昨天）。
class _QuickDateChip extends StatelessWidget {
  const _QuickDateChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: selected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
