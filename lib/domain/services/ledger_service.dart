import '../../core/uuid.dart';
import '../../data/database.dart' hide Ledger, Category;
import '../models/category.dart';
import '../models/ledger.dart';

/// Ledger CRUD plus default built-in categories for a new ledger owner.
class LedgerService {
  LedgerService(this._db);

  final AppDatabase _db;

  static const List<Map<String, String>> defaultCategories = <Map<String, String>>[
    <String, String>{'name': '餐饮', 'type': 'expense', 'icon': '🍜', 'color': '#C6A15B'},
    <String, String>{'name': '交通', 'type': 'expense', 'icon': '🚇', 'color': '#1F6F5C'},
    <String, String>{'name': '购物', 'type': 'expense', 'icon': '🛍️', 'color': '#C05B4D'},
    <String, String>{'name': '居住', 'type': 'expense', 'icon': '🏠', 'color': '#4C9C86'},
    <String, String>{'name': '其他', 'type': 'expense', 'icon': '📌', 'color': '#6B7772'},
    <String, String>{'name': '工资', 'type': 'income', 'icon': '💰', 'color': '#1F6F5C'},
    <String, String>{'name': '其他', 'type': 'income', 'icon': '📌', 'color': '#6B7772'},
  ];

  Future<Ledger> createLedger({
    required String userId,
    required String name,
    String icon = '📒',
    String color = '#1F6F5C',
    bool seedCategories = true,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(name, 'name', '账本名称不能为空');
    }
    final now = DateTime.now().toUtc();
    final ledger = Ledger(
      id: Uuid.v4(),
      userId: userId,
      name: trimmed,
      icon: icon,
      color: color,
      sortOrder: (await _db.ledgerDao.findAll()).length,
      createdAt: now,
      updatedAt: now,
    );
    await _db.transaction(() async {
      await _db.ledgerDao.save(ledger);
      if (seedCategories) {
        final existing = await _db.categoryDao.findAll();
        if (existing.isEmpty) {
          for (final item in defaultCategories) {
            await _db.categoryDao.save(
              Category(
                id: Uuid.v4(),
                userId: userId,
                name: item['name']!,
                type: item['type']!,
                icon: item['icon']!,
                color: item['color']!,
                isCustom: false,
                sortOrder: 0,
              ),
            );
          }
        }
      }
    });
    return ledger;
  }
}
