import 'package:flutter/material.dart';

import '../../core/layout_tokens.dart';

/// 限宽居中容器（架构 §4 组件 6）。
///
/// 整页内容用默认 [AppLayout.contentMaxWidth]；两栏中的单列传 480 / 320 / 880。
/// 注意：compact 档**不要**用它包整页（手机端不需要 1200px 约束，
/// 由 `ResponsiveScaffold` 的早返回分支统一杜绝）。
class ContentContainer extends StatelessWidget {
  const ContentContainer({
    super.key,
    required this.child,
    this.maxWidth = AppLayout.contentMaxWidth,
    this.padding,
    this.alignment = Alignment.topCenter,
    this.fillHeight = false,
  });

  /// 内容节点。
  final Widget child;

  /// 宽度上限。
  final double maxWidth;

  /// 容器内边距（默认无，避免与页面 `pagePadding` 双重施加）。
  final EdgeInsets? padding;

  /// 小于上限时的对齐方式。
  final Alignment alignment;

  /// 需要 `Column + Expanded` 的页面（如统计页）置 true，获得有界高度。
  final bool fillHeight;

  @override
  Widget build(BuildContext context) {
    final EdgeInsets? innerPadding = padding;
    Widget content = innerPadding == null
        ? child
        : Padding(padding: innerPadding, child: child);
    if (fillHeight) {
      content = SizedBox.expand(child: content);
    }
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: content,
      ),
    );
  }
}
