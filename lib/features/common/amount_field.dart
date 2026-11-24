import 'package:flutter/material.dart';

import '../../core/money.dart';

/// Yuan text input with a live integer-cents value. No double ever reaches storage.
class AmountField extends StatefulWidget {
  const AmountField({
    super.key,
    required this.onCentsChanged,
    this.initialCents = 0,
    this.label = '金额',
  });

  final ValueChanged<int?> onCentsChanged;
  final int initialCents;
  final String label;

  @override
  State<AmountField> createState() => _AmountFieldState();
}

class _AmountFieldState extends State<AmountField> {
  late final TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialCents == 0 ? '' : Money.plainCents(widget.initialCents),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: widget.label,
        prefixText: '¥ ',
        errorText: _error,
        helperText: '支持 万 / 千 / 百 快捷单位',
      ),
      onChanged: (value) {
        if (value.trim().isEmpty) {
          setState(() => _error = null);
          widget.onCentsChanged(null);
          return;
        }
        try {
          final cents = Money.parseYuanToCents(value);
          setState(() => _error = null);
          widget.onCentsChanged(cents);
        } on FormatException {
          setState(() => _error = '请输入有效金额');
          widget.onCentsChanged(null);
        } on ArgumentError {
          setState(() => _error = '金额过大');
          widget.onCentsChanged(null);
        }
      },
    );
  }
}
