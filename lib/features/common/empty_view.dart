import 'package:flutter/material.dart';

import '../../core/theme.dart';
import 'app_buttons.dart';

/// 空状态视图。
///
/// v4：新增可选 [iconSize]（默认 56，桌面传 64）与 [maxWidth]（默认无约束，
/// 桌面传 400 收窄文案行长）；默认值保持改造前观感不变。
class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.iconSize = 56,
    this.maxWidth,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// 插画图标尺寸。
  final double iconSize;

  /// 文案区最大宽度（null = 不限制，等同改造前）。
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final String? label = actionLabel;
    final VoidCallback? action = onAction;
    final Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: iconSize, color: AppColors.gold),
        const SizedBox(height: 16),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (label != null && action != null) ...<Widget>[
          const SizedBox(height: 20),
          AppButton.primary(label: label, onPressed: action),
        ],
      ],
    );

    final double? limit = maxWidth;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: limit == null
            ? content
            : ConstrainedBox(
                constraints: BoxConstraints(maxWidth: limit),
                child: content,
              ),
      ),
    );
  }
}
