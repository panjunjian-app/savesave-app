import 'package:flutter/material.dart';

import '../../core/layout_tokens.dart';
import '../../core/theme.dart';

/// 行式表格的一列定义（架构 §4 组件 9）。
class AppTableColumn<T> {
  const AppTableColumn({
    required this.label,
    required this.cell,
    this.flex = 1,
    this.minWidth = 72,
    this.align = TextAlign.start,
    this.numeric = false,
  });

  /// 表头文案。
  final String label;

  /// 单元格构建器。
  final Widget Function(BuildContext context, T row) cell;

  /// 弹性权重。
  final int flex;

  /// 最小宽度（用于决定是否降级为行卡片，保证无横向滚动）。
  final double minWidth;

  /// 单元格对齐方式。
  final TextAlign align;

  /// 是否数值列（等宽数字 + 右对齐）。
  final bool numeric;
}

/// 行式表格：吸顶表头 + 行 hover 高亮 + 金额等宽右对齐。
///
/// 决策（PRD Q2 / 架构 A3）：不用 `DataTable`，且**仅在 expanded 档使用**；
/// 容器宽度小于列最小宽之和时自动降级为行卡片，从结构上保证「无横向滚动」。
class AppTableView<T> extends StatelessWidget {
  const AppTableView({
    super.key,
    required this.rows,
    required this.columns,
    this.onRowTap,
    this.emptyHint,
    this.rowHeight = AppLayout.tableRowHeight,
  });

  /// 数据行。
  final List<T> rows;

  /// 列定义。
  final List<AppTableColumn<T>> columns;

  /// 行点击回调。
  final void Function(T row)? onRowTap;

  /// 空态提示文案。
  final String? emptyHint;

  /// 行高。
  final double rowHeight;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return Center(
        child: Text(
          emptyHint ?? '暂无数据',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }

    double minTotal = 0;
    for (final AppTableColumn<T> column in columns) {
      minTotal += column.minWidth;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < minTotal) {
          // 结构降级：宽度不足时改行卡片，避免横向溢出（O-1）。
          return _buildDegradedList(context);
        }
        return CustomScrollView(
          slivers: <Widget>[
            SliverPersistentHeader(
              pinned: true,
              delegate: _HeaderDelegate(
                child: _buildHeaderRow(context),
                height: AppLayout.tableHeaderHeight,
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildRow(context, index),
                childCount: rows.length,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeaderRow(BuildContext context) {
    return Container(
      height: AppLayout.tableHeaderHeight,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: columns
            .map(
              (column) => Expanded(
                flex: column.flex,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Align(
                    alignment: _alignmentOf(column),
                    child: Text(
                      column.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }

  Widget _buildRow(BuildContext context, int index) {
    final T row = rows[index];
    final void Function(T row)? tap = onRowTap;
    return Container(
      height: rowHeight,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: tap == null ? null : () => tap(row),
          hoverColor: AppColors.primary.withValues(alpha: 0.04),
          child: Row(
            children: columns
                .map(
                  (column) => Expanded(
                    flex: column.flex,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Align(
                        alignment: _alignmentOf(column),
                        child: DefaultTextStyle.merge(
                          style: column.numeric
                              ? AppTheme.tableNumericStyle
                              : const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                          child: column.cell(context, row),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ),
      ),
    );
  }

  Widget _buildDegradedList(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: rows.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final T row = rows[index];
        final void Function(T row)? tap = onRowTap;
        return InkWell(
          onTap: tap == null ? null : () => tap(row),
          hoverColor: AppColors.primary.withValues(alpha: 0.04),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: columns
                  .map(
                    (column) => Expanded(
                      flex: column.flex,
                      child: Align(
                        alignment: _alignmentOf(column),
                        child: column.cell(context, row),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
        );
      },
    );
  }

  Alignment _alignmentOf(AppTableColumn<T> column) {
    if (column.numeric || column.align == TextAlign.right) {
      return Alignment.centerRight;
    }
    if (column.align == TextAlign.center) {
      return Alignment.center;
    }
    return Alignment.centerLeft;
  }
}

class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  _HeaderDelegate({required this.child, required this.height});

  final Widget child;
  final double height;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(color: AppColors.surface, child: child);
  }

  @override
  bool shouldRebuild(_HeaderDelegate oldDelegate) {
    return oldDelegate.child != child || oldDelegate.height != height;
  }
}
