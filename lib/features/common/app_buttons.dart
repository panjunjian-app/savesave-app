import 'package:flutter/material.dart';

import '../../core/breakpoints.dart';
import '../../core/layout_tokens.dart';
import '../../core/theme.dart';

/// 按钮类型的内部枚举。
enum _AppButtonKind { primary, secondary, text, danger }

/// 按钮宽度单点管控（架构 A4 / PRD §4.1）。
///
/// 全站**禁止** `Size.fromHeight`：桌面档单个按钮 120–240px；
/// compact 档内部还原改造前的全宽观感（唯一允许的全宽例外）。
abstract final class AppButton {
  /// 主操作按钮（FilledButton）。
  static Widget primary({
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    bool busy = false,
    Color? backgroundColor,
  }) {
    return _AppButton(
      kind: _AppButtonKind.primary,
      label: label,
      onPressed: onPressed,
      icon: icon,
      busy: busy,
      backgroundColor: backgroundColor,
    );
  }

  /// 次级操作按钮（OutlinedButton）。
  static Widget secondary({
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    bool busy = false,
  }) {
    return _AppButton(
      kind: _AppButtonKind.secondary,
      label: label,
      onPressed: onPressed,
      icon: icon,
      busy: busy,
    );
  }

  /// 文字按钮（TextButton）；compact 下也保持内容宽度。
  static Widget text({
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    bool busy = false,
    TextStyle? textStyle,
  }) {
    return _AppButton(
      kind: _AppButtonKind.text,
      label: label,
      onPressed: onPressed,
      icon: icon,
      busy: busy,
      textStyle: textStyle,
    );
  }

  /// 危险操作按钮（红色描边）。
  static Widget danger({
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    bool busy = false,
  }) {
    return _AppButton(
      kind: _AppButtonKind.danger,
      label: label,
      onPressed: onPressed,
      icon: icon,
      busy: busy,
    );
  }
}

class _AppButton extends StatelessWidget {
  const _AppButton({
    required this.kind,
    required this.label,
    this.onPressed,
    this.icon,
    this.busy = false,
    this.backgroundColor,
    this.textStyle,
  });

  final _AppButtonKind kind;
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool busy;

  /// 主按钮的自定义底色（例如「有新版」转金色），其余类型忽略。
  final Color? backgroundColor;

  /// 文字按钮的字号覆写（用于保持改造前 13px 的次要链接观感）。
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final compact = context.isCompact;
    final VoidCallback? handler = busy ? null : onPressed;
    final Widget content = _buildContent();

    final Widget button;
    switch (kind) {
      case _AppButtonKind.primary:
        final Color? background = backgroundColor;
        button = FilledButton(
          onPressed: handler,
          style: background == null
              ? null
              : FilledButton.styleFrom(backgroundColor: background),
          child: content,
        );
        break;
      case _AppButtonKind.secondary:
        button = OutlinedButton(onPressed: handler, child: content);
        break;
      case _AppButtonKind.text:
        final TextStyle? style = textStyle;
        button = TextButton(
          onPressed: handler,
          style: style == null ? null : TextButton.styleFrom(textStyle: style),
          child: content,
        );
        break;
      case _AppButtonKind.danger:
        button = OutlinedButton(
          onPressed: handler,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.danger,
            side: const BorderSide(color: AppColors.danger),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
          child: content,
        );
        break;
    }

    if (!compact) {
      // 桌面：单按钮宽度锁定在 120–240。
      return ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: AppLayout.buttonMinWidth,
          maxWidth: AppLayout.buttonMaxWidth,
          minHeight: AppLayout.buttonHeight,
        ),
        child: button,
      );
    }

    if (kind == _AppButtonKind.text) {
      // 文字按钮在手机端本就是内容宽度，保持原样。
      return button;
    }
    // 手机端还原改造前的全宽观感（等价于旧的 Size.fromHeight(48)）。
    return SizedBox(
      width: double.infinity,
      height: AppLayout.buttonHeight,
      child: button,
    );
  }

  Widget _buildContent() {
    if (busy) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      );
    }
    final IconData? iconData = icon;
    if (iconData == null) {
      return Text(label, maxLines: 1, overflow: TextOverflow.ellipsis);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(iconData, size: 18),
        const SizedBox(width: 8),
        Flexible(
          child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

/// 表单底部按钮组（PRD §4.1）：桌面右对齐、手机端保持纵向全宽顺序。
class FormActionBar extends StatelessWidget {
  const FormActionBar({
    super.key,
    required this.primary,
    this.secondary,
    this.alignment = Alignment.centerRight,
  });

  /// 主操作（保存 / 提交）。
  final Widget primary;

  /// 次级操作（取消 / 辅助），可为空。
  final Widget? secondary;

  /// 桌面档按钮组的水平对齐。
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final Widget? secondaryWidget = secondary;
    if (context.isCompact) {
      // 旧路径：纵向排列，主操作在最下方，与改造前一致。
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (secondaryWidget != null) ...<Widget>[
            secondaryWidget,
            const SizedBox(height: AppLayout.blockGap),
          ],
          primary,
        ],
      );
    }
    return Row(
      mainAxisAlignment: _mainAxisAlignment,
      children: <Widget>[
        if (secondaryWidget != null) ...<Widget>[
          secondaryWidget,
          const SizedBox(width: AppLayout.blockGap),
        ],
        primary,
      ],
    );
  }

  MainAxisAlignment get _mainAxisAlignment {
    if (alignment == Alignment.centerLeft) {
      return MainAxisAlignment.start;
    }
    if (alignment == Alignment.center) {
      return MainAxisAlignment.center;
    }
    return MainAxisAlignment.end;
  }
}
