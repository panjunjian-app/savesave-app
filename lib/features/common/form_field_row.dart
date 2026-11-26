import 'package:flutter/material.dart';

import '../../core/breakpoints.dart';
import '../../core/layout_tokens.dart';
import '../../core/theme.dart';

/// 桌面「左标签 + 右控件」表单单元（架构 §4 组件 10）。
///
/// compact 档**直接返回 [child]**：标签仍由 `InputDecoration.labelText` 承担，
/// 与改造前的浮动 label 堆叠逐像素一致（Shared Knowledge §2）。
class FormRow extends StatelessWidget {
  const FormRow({super.key, required this.label, required this.child});

  /// 桌面档左侧固定 120px 的标签文案。
  final String label;

  /// 右侧控件（通常是 TextField / 下拉 / 开关）。
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (context.isCompact) {
      return child;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: AppLayout.blockGap),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: AppLayout.fieldLabelWidth,
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppLayout.cardGap),
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// 输入框装饰的统一构造：compact 用 `labelText`（现状），桌面用 `hintText` + 左标签。
abstract final class AppInput {
  /// 按断点返回合适的 [InputDecoration]。
  static InputDecoration decoration(
    BuildContext context, {
    required String label,
    String? hint,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? errorText,
  }) {
    if (context.isCompact) {
      return InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        errorText: errorText,
      );
    }
    // 桌面：标签在左侧（FormRow），控件内只保留占位提示，行高压缩到 44。
    return InputDecoration(
      hintText: hint ?? label,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      errorText: errorText,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
    );
  }
}
