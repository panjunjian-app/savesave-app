import 'package:drift/drift.dart';

import '../database.dart';
import '../tables.dart';
import '../../domain/models/category.dart' as model;

part 'category_dao.g.dart';

/// Data access for income/expense categories.
@DriftAccessor(tables: [Categories])
class CategoryDao extends DatabaseAccessor<AppDatabase> with _$CategoryDaoMixin {
  CategoryDao(super.attachedDatabase);

  Stream<List<model.Category>> watchAll() {
    final query = select(categories)
      ..orderBy([
        (row) => OrderingTerm.asc(row.sortOrder),
        (row) => OrderingTerm.asc(row.name),
      ]);
    return query
        .watch()
        .map((rows) => rows.map(_map).toList(growable: false));
  }

  Future<List<model.Category>> findAll() async {
    final rows = await select(categories).get();
    return rows.map(_map).toList(growable: false);
  }

  Future<model.Category?> findByNameAndType(String name, String type) async {
    final rows = await (select(categories)
          ..where((row) => row.name.equals(name) & row.type.equals(type)))
        .get();
    return rows.isEmpty ? null : _map(rows.first);
  }

  Future<int> deleteAll() => delete(categories).go();

  Future<void> save(model.Category category) async {
    await into(categories).insert(
          CategoriesCompanion.insert(
            id: category.id,
            userId: category.userId,
            name: category.name,
            type: category.type,
            icon: Value(category.icon),
            color: Value(category.color),
            isCustom: Value(category.isCustom),
            sortOrder: Value(category.sortOrder),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  model.Category _map(Category row) => model.Category(
        id: row.id,
        userId: row.userId,
        name: row.name,
        type: row.type,
        icon: row.icon,
        color: row.color,
        isCustom: row.isCustom,
        sortOrder: row.sortOrder,
      );
}
