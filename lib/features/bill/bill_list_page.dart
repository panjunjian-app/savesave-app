import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/breakpoints.dart';
import '../../core/layout_tokens.dart';
import '../../core/money.dart';
import '../../core/theme.dart';
import '../../domain/models/bill.dart';
import '../../domain/models/category.dart';
import '../../domain/models/ledger.dart';
import '../../state/providers.dart';
import '../common/app_buttons.dart';
import '../common/data_table_view.dart';
import '../common/empty_view.dart';
import '../common/responsive_scaffold.dart';

/// 桌面工具条的时间范围选项。
enum _BillRange { all, last7, last30, thisYear }

class BillListPage extends ConsumerStatefulWidget {
  const BillListPage({super.key});

  @override
  ConsumerState<BillListPage> createState() => _BillListPageState();
}

class _BillListPageState extends ConsumerState<BillListPage> {
  final TextEditingController _searchController = TextEditingController();
  _BillRange _range = _BillRange.all;
  String _keyword = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ledgerKey = ref.watch(selectedLedgerIdProvider);
    final billsAsync = ref.watch(billsByLedgerProvider(ledgerKey));
    final ledgersAsync = ref.watch(ledgersProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final ledgers = ledgersAsync.valueOrNull ?? const <Ledger>[];
    final categories = categoriesAsync.valueOrNull ?? const <Category>[];
    final compact = context.isCompact;
    final ledgerName = ledgerKey == Ledger.allKey
        ? '全部账本'
        : ledgers.where((l) => l.id == ledgerKey).firstOrNull?.name ?? '账本';

    return ResponsiveScaffold(
      title: compact ? '$ledgerName · 账单明细' : '账单明细',
      fillHeight: true,
      // /bills 不在手机端底部 Tab 白名单里（架构 §3.2），没有返回箭头会成为死路：
      // 记一笔 → 返回 → 账单明细后无处可去。桌面端该页是侧栏一级入口，不需要箭头。
      backLocation: compact ? '/home' : null,
      actions: <Widget>[
        if (compact)
          PopupMenuButton<String>(
            onSelected: (value) =>
                ref.read(selectedLedgerIdProvider.notifier).state = value,
            itemBuilder: (context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(value: Ledger.allKey, child: Text('全部账本')),
              ...ledgers.map(
                (ledger) => PopupMenuItem<String>(
                  value: ledger.id,
                  child: Text(ledger.name),
                ),
              ),
            ],
          ),
      ],
      primaryAction: AppButton.primary(
        label: '记一笔',
        icon: Icons.add,
        onPressed: () => context.go('/bills/new'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/bills/new'),
        backgroundColor: AppColors.gold,
        child: const Icon(Icons.add),
      ),
      body: billsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('加载失败：$error')),
        data: (bills) {
          if (bills.isEmpty) {
            return EmptyView(
              icon: Icons.receipt_long_outlined,
              title: '还没有账单',
              message: compact ? '点击右下角按钮记下第一笔收支。' : '点击右上角「记一笔」记下第一笔收支。',
              iconSize: compact ? 56 : 64,
              maxWidth: compact ? null : 400,
            );
          }
          if (compact) {
            return _buildCompactList(bills);
          }
          if (context.breakpoint == AppBreakpoint.medium) {
            // 结构约束：表格只在 expanded 档启用，medium 沿用列表（架构 A3 / O-1）。
            return _buildMediumList(bills);
          }
          return _buildDesktopBody(bills, ledgers, categories);
        },
      ),
    );
  }

  /// 手机端列表：与改造前逐字一致。
  Widget _buildCompactList(List<Bill> bills) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: bills.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final bill = bills[index];
        return ListTile(
          title: Text(
            bill.note ?? (bill.isIncome ? '收入' : '支出'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text('${bill.billDate} · ${bill.source}'),
          trailing: Text(
            '${bill.isIncome ? '+' : '-'}${Money.formatCents(bill.amountCents)}',
            style: TextStyle(
              color: bill.isIncome ? AppColors.primary : AppColors.danger,
              fontWeight: FontWeight.w700,
            ),
          ),
          onTap: () => context.go('/bills/${bill.id}'),
        );
      },
    );
  }

  /// medium 档（600–1023）：沿用列表形态，只把内边距换成断点 token。
  Widget _buildMediumList(List<Bill> bills) {
    return ListView.separated(
      padding: context.pagePadding,
      itemCount: bills.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final bill = bills[index];
        return ListTile(
          title: Text(
            bill.note ?? (bill.isIncome ? '收入' : '支出'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text('${bill.billDate} · ${bill.source}'),
          trailing: Text(
            '${bill.isIncome ? '+' : '-'}${Money.formatCents(bill.amountCents)}',
            style: TextStyle(
              color: bill.isIncome ? AppColors.primary : AppColors.danger,
              fontWeight: FontWeight.w700,
            ),
          ),
          onTap: () => context.go('/bills/${bill.id}'),
        );
      },
    );
  }

  /// 桌面端：顶部工具条 + 6 列表格（表头吸顶）。
  Widget _buildDesktopBody(
    List<Bill> bills,
    List<Ledger> ledgers,
    List<Category> categories,
  ) {
    final ledgerKey = ref.watch(selectedLedgerIdProvider);
    final Map<String, String> ledgerNames = <String, String>{
      for (final Ledger ledger in ledgers) ledger.id: ledger.name,
    };
    final Map<String, Category> categoryById = <String, Category>{
      for (final Category category in categories) category.id: category,
    };
    final List<Bill> filtered = _applyFilters(bills, categoryById);
    final EdgeInsets pagePad = context.pagePadding;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          // 工具条与表格使用同一水平内距（QA P2-2：避免表头/行顶到内容区边缘）。
          padding: EdgeInsets.fromLTRB(pagePad.left, 20, pagePad.right, 12),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 180,
                child: DropdownButtonFormField<String>(
                  initialValue: ledgerKey,
                  decoration: const InputDecoration(isDense: true),
                  items: <DropdownMenuItem<String>>[
                    const DropdownMenuItem<String>(
                      value: Ledger.allKey,
                      child: Text('全部账本'),
                    ),
                    ...ledgers.map(
                      (ledger) => DropdownMenuItem<String>(
                        value: ledger.id,
                        child: Text(ledger.name),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(selectedLedgerIdProvider.notifier).state = value;
                    }
                  },
                ),
              ),
              const SizedBox(width: AppLayout.blockGap),
              SizedBox(
                width: 160,
                child: DropdownButtonFormField<_BillRange>(
                  initialValue: _range,
                  decoration: const InputDecoration(isDense: true),
                  items: const <DropdownMenuItem<_BillRange>>[
                    DropdownMenuItem<_BillRange>(
                      value: _BillRange.all,
                      child: Text('全部时间'),
                    ),
                    DropdownMenuItem<_BillRange>(
                      value: _BillRange.last7,
                      child: Text('近 7 天'),
                    ),
                    DropdownMenuItem<_BillRange>(
                      value: _BillRange.last30,
                      child: Text('近 30 天'),
                    ),
                    DropdownMenuItem<_BillRange>(
                      value: _BillRange.thisYear,
                      child: Text('本年'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _range = value);
                    }
                  },
                ),
              ),
              const SizedBox(width: AppLayout.blockGap),
              Flexible(
                child: SizedBox(
                  width: 320,
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      isDense: true,
                      hintText: '搜索备注 / 分类 / 金额',
                      prefixIcon: Icon(Icons.search, size: 18),
                    ),
                    onChanged: (value) => setState(() => _keyword = value),
                  ),
                ),
              ),
              const SizedBox(width: AppLayout.blockGap),
              Text(
                '共 ${filtered.length} 条',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: pagePad.left),
            child: AppTableView<Bill>(
              rows: filtered,
              emptyHint: '没有符合条件的账单',
              onRowTap: (bill) => context.go('/bills/${bill.id}'),
              columns: <AppTableColumn<Bill>>[
                AppTableColumn<Bill>(
                  label: '日期',
                  flex: 2,
                  minWidth: 96,
                  cell: (context, bill) => Text(bill.billDate),
                ),
                AppTableColumn<Bill>(
                  label: '分类',
                  flex: 2,
                  minWidth: 96,
                  cell: (context, bill) {
                    final category = categoryById[bill.categoryId];
                    if (category == null) {
                      return const Text('—');
                    }
                    return Text(
                      '${category.icon} ${category.name}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                ),
                AppTableColumn<Bill>(
                  label: '备注',
                  flex: 3,
                  minWidth: 140,
                  cell: (context, bill) => Text(
                    bill.note ?? (bill.isIncome ? '收入' : '支出'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                AppTableColumn<Bill>(
                  label: '账本',
                  flex: 2,
                  minWidth: 100,
                  cell: (context, bill) => Text(
                    ledgerNames[bill.ledgerId] ?? '—',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                AppTableColumn<Bill>(
                  label: '金额',
                  flex: 2,
                  minWidth: 120,
                  numeric: true,
                  align: TextAlign.right,
                  cell: (context, bill) => Text(
                    '${bill.isIncome ? '+' : '-'}${Money.formatCents(bill.amountCents)}',
                    maxLines: 1,
                    style: TextStyle(
                      color: bill.isIncome ? AppColors.primary : AppColors.danger,
                    ),
                  ),
                ),
                AppTableColumn<Bill>(
                  label: '操作',
                  flex: 1,
                  minWidth: 88,
                  align: TextAlign.right,
                  cell: (context, bill) => TextButton(
                    onPressed: () => context.go('/bills/${bill.id}'),
                    child: const Text('查看'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 本地过滤（不改任何业务计算：仅在已加载的账单上筛选展示）。
  List<Bill> _applyFilters(
    List<Bill> bills,
    Map<String, Category> categoryById,
  ) {
    final String keyword = _keyword.trim().toLowerCase();
    final String? cutoff = _cutoffDate();
    return bills.where((bill) {
      if (cutoff != null && bill.billDate.compareTo(cutoff) < 0) {
        return false;
      }
      if (keyword.isEmpty) {
        return true;
      }
      final category = categoryById[bill.categoryId];
      final haystack = <String>[
        bill.billDate,
        bill.note ?? '',
        category?.name ?? '',
        Money.formatCents(bill.amountCents),
      ].join(' ').toLowerCase();
      return haystack.contains(keyword);
    }).toList(growable: false);
  }

  /// 时间范围对应的起始日期（yyyy-MM-dd），null 表示不限。
  String? _cutoffDate() {
    final now = DateTime.now();
    switch (_range) {
      case _BillRange.all:
        return null;
      case _BillRange.last7:
        return _isoDate(now.subtract(const Duration(days: 7)));
      case _BillRange.last30:
        return _isoDate(now.subtract(const Duration(days: 30)));
      case _BillRange.thisYear:
        return _isoDate(DateTime(now.year, 1, 1));
    }
  }

  String _isoDate(DateTime date) {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${date.year}-${two(date.month)}-${two(date.day)}';
  }
}
