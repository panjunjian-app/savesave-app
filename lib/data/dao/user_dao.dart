import 'package:drift/drift.dart';

import '../database.dart';
import '../tables.dart';
import '../../domain/models/user.dart' as model;

part 'user_dao.g.dart';

/// Data access for local user profiles.
@DriftAccessor(tables: [Users])
class UserDao extends DatabaseAccessor<AppDatabase> with _$UserDaoMixin {
  UserDao(super.attachedDatabase);

  Stream<model.User?> watchById(String id) {
    return (select(users)..where((row) => row.id.equals(id)))
        .watch()
        .map((rows) => rows.isEmpty ? null : _map(rows.first));
  }

  Future<model.User?> findByOpenid(String openid) async {
    final rows = await (select(users)..where((row) => row.openid.equals(openid))).get();
    return rows.isEmpty ? null : _map(rows.first);
  }

  /// Email comparison is case-insensitive: stored lowercase at write time,
  /// query also lowercases to survive any legacy mixed-case rows.
  Future<model.User?> findByEmail(String email) async {
    final rows = await (select(users)
          ..where((row) => row.email.equals(email.toLowerCase())))
        .get();
    return rows.isEmpty ? null : _map(rows.first);
  }

  Future<model.User?> findById(String id) async {
    final rows = await (select(users)..where((row) => row.id.equals(id))).get();
    return rows.isEmpty ? null : _map(rows.first);
  }

  Future<void> save(model.User user) async {
    await into(users).insert(
          UsersCompanion.insert(
            id: user.id,
            openid: Value(user.openid),
            unionid: Value(user.unionid),
            email: Value(user.email?.toLowerCase()),
            passwordHash: Value(user.passwordHash),
            nickname: Value(user.nickname),
            avatarUrl: Value(user.avatarUrl),
            loginType: Value(user.loginType),
            createdAt: user.createdAt.toUtc().toIso8601String(),
            updatedAt: user.updatedAt.toUtc().toIso8601String(),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  Future<void> remove(String id) async {
    await (delete(users)..where((row) => row.id.equals(id))).go();
  }

  model.User _map(User row) => model.User(
        id: row.id,
        openid: row.openid,
        unionid: row.unionid,
        email: row.email,
        passwordHash: row.passwordHash,
        nickname: row.nickname,
        avatarUrl: row.avatarUrl,
        loginType: row.loginType,
        createdAt: DateTime.parse(row.createdAt),
        updatedAt: DateTime.parse(row.updatedAt),
      );
}
