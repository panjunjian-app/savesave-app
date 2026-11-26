import 'package:flutter/material.dart';

import '../../core/layout_tokens.dart';

/// 卡片 1 / 2 / 3 列自适应网格（架构 §4 组件 8）。
///
/// 列数规则映射 PRD「>=1440 三列 / 1024–1439 两列 / 768–1023 两列 / <768 单列」：
/// 容器宽 >= 1120 → 3 列；>= 700 → 2 列；否则单列。
/// 同一行的卡片用 [IntrinsicHeight] 拉齐等高。
class AdaptiveGrid extends StatelessWidget {
  const AdaptiveGrid({
    super.key,
    required this.children,
    this.minItemWidth = 320,
    this.spacing = AppLayout.cardGap,
    this.maxColumns = 3,
    this.runSpacing,
  });

  /// 网格子项（通常是卡片）。
  final List<Widget> children;

  /// 单列最小宽度（仅用于 1 列时的可读性判断）。
  final double minItemWidth;

  /// 列间距。
  final double spacing;

  /// 最大列数。
  final int maxColumns;

  /// 行间距，默认等于 [spacing]。
  final double? runSpacing;

  /// 容器宽度到列数的映射（供页面 / 测试复用）。
  static int columnsFor(
    double width, {
    double minItemWidth = 320,
    int maxColumns = 3,
  }) {
    if (maxColumns <= 1 || width < 700) {
      return 1;
    }
    if (width >= 1120 && maxColumns >= 3) {
      return 3;
    }
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }
    final double rowGap = runSpacing ?? spacing;
    return LayoutBuilder(
      builder: (context, constraints) {
        final int columns = columnsFor(
          constraints.maxWidth,
          minItemWidth: minItemWidth,
          maxColumns: maxColumns,
        );
        if (columns <= 1) {
          final List<Widget> stacked = <Widget>[];
          for (int i = 0; i < children.length; i++) {
            if (i > 0) {
              stacked.add(SizedBox(height: rowGap));
            }
            stacked.add(children[i]);
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: stacked,
          );
        }

        final List<Widget> rows = <Widget>[];
        for (int start = 0; start < children.length; start += columns) {
          final int end = (start + columns).clamp(0, children.length);
          final List<Widget> cells = <Widget>[];
          for (int i = start; i < end; i++) {
            if (i > start) {
              cells.add(SizedBox(width: spacing));
            }
            cells.add(Expanded(child: children[i]));
          }
          // 末行不足列数时用空占位补齐，保证各列宽度一致。
          for (int i = end - start; i < columns; i++) {
            cells.add(SizedBox(width: spacing));
            cells.add(const Expanded(child: SizedBox.shrink()));
          }
          if (rows.isNotEmpty) {
            rows.add(SizedBox(height: rowGap));
          }
          rows.add(
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: cells,
              ),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: rows,
        );
      },
    );
  }
}
