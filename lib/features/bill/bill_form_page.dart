import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme.dart';
import '../../data/services/ai_client.dart';
import '../../state/providers.dart';
import '../common/amount_field.dart';

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
    if (selected.isNotEmpty && selected != 'all') {
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
    final categories = (categoriesAsync.valueOrNull ?? const [])
        .where((category) => category.type == _type)
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(title: const Text('记一笔')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          SegmentedButton<String>(
            segments: const <ButtonSegment<String>>[
              ButtonSegment<String>(value: 'expense', label: Text('支出')),
              ButtonSegment<String>(value: 'income', label: Text('收入')),
            ],
            selected: <String>{_type},
            onSelectionChanged: (values) => setState(() {
              _type = values.first;
              _categoryId = null;
            }),
          ),
          const SizedBox(height: 16),
          AmountField(
            onCentsChanged: (cents) => setState(() => _amountCents = cents),
          ),
          const SizedBox(height: 16),
          ledgersAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (error, _) => Text('账本加载失败：$error'),
            data: (ledgers) => DropdownButtonFormField<String>(
              initialValue: _ledgerId,
              decoration: const InputDecoration(labelText: '账本'),
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
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
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
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('账单日期'),
            subtitle: Text(_billDate),
            trailing: const Icon(Icons.calendar_today_outlined),
            onTap: _pickDate,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _noteController,
            maxLines: 2,
            decoration: const InputDecoration(labelText: '备注（可选）'),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _recognizing ? null : _recognizeFromImage,
            icon: _recognizing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.image_outlined),
            label: Text(_recognizing ? '识别中...' : '上传小票，AI 自动填入'),
          ),
          if (_image != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '已选择图片：${_image!.name}（保存前请核对所有字段）',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
          if (_error != null) ...<Widget>[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: AppColors.danger)),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? '保存中...' : '保存账单'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
