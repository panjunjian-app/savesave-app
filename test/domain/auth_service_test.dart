import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:savesave/data/database.dart';
import 'package:savesave/domain/services/auth_service.dart';

/// 邮箱注册/登录/游客升级测试（内存 SQLite + 内存 SharedPreferences）。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late AuthService service;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    db = AppDatabase.forTesting(NativeDatabase.memory());
    service = AuthService(db, prefs: prefs);
  });

  tearDown(() async {
    await db.close();
  });

  group('AuthService 校验规则', () {
    test('邮箱格式校验', () {
      expect(AuthService.validateEmail('a@b.com'), isNull);
      expect(AuthService.validateEmail(' user.tag+1@sub.example.cn '), isNull);
      expect(AuthService.validateEmail(''), isNotNull);
      expect(AuthService.validateEmail('not-an-email'), isNotNull);
      expect(AuthService.validateEmail('a@b'), isNotNull);
    });

    test('密码校验：至少 6 位、最多 64 位', () {
      expect(AuthService.validatePassword('123456'), isNull);
      expect(AuthService.validatePassword('12345'), isNotNull);
      expect(AuthService.validatePassword(''), isNotNull);
      expect(AuthService.validatePassword('x' * 65), isNotNull);
    });
  });

  group('AuthService 邮箱注册与登录', () {
    test('注册成功并自动登录本地会话', () async {
      final user = await service.signUpWithEmail(
        email: 'Pan@Test.COM',
        password: 'secret6',
      );
      expect(user.loginType, 'email');
      expect(user.email, 'pan@test.com'); // 存库统一小写
      expect(user.passwordHash, isNotNull);
      expect(user.passwordHash, isNot('secret6')); // 明文不落库

      final restored = await service.restoreLocalUser();
      expect(restored?.id, user.id);
    });

    test('重复注册同一邮箱被拒绝', () async {
      await service.signUpWithEmail(email: 'a@b.com', password: 'secret6');
      expect(
        () => service.signUpWithEmail(email: 'a@b.com', password: 'other66'),
        throwsA(isA<AuthFailure>()),
      );
    });

    test('注册弱密码被拒绝', () async {
      expect(
        () => service.signUpWithEmail(email: 'a@b.com', password: '123'),
        throwsA(isA<AuthFailure>()),
      );
    });

    test('正确密码登录成功', () async {
      await service.signUpWithEmail(email: 'a@b.com', password: 'secret6');
      final user = await service.signInWithEmail(
        email: 'A@B.com',
        password: 'secret6',
      );
      expect(user.email, 'a@b.com');
    });

    test('错误密码登录失败', () async {
      await service.signUpWithEmail(email: 'a@b.com', password: 'secret6');
      expect(
        () => service.signInWithEmail(email: 'a@b.com', password: 'wrong66'),
        throwsA(isA<AuthFailure>()),
      );
    });

    test('未注册邮箱登录被拒绝', () async {
      expect(
        () => service.signInWithEmail(email: 'nobody@b.com', password: 'secret6'),
        throwsA(isA<AuthFailure>()),
      );
    });

    test('游客注册后升级为邮箱账号，游客数据沿用同一 user id', () async {
      final guest = await service.signInAsGuest();
      expect(guest.loginType, 'guest');

      final upgraded = await service.signUpWithEmail(
        email: 'a@b.com',
        password: 'secret6',
      );
      expect(upgraded.id, guest.id);
      expect(upgraded.loginType, 'email');
    });

    test('登出后 restoreLocalUser 返回 null', () async {
      await service.signUpWithEmail(email: 'a@b.com', password: 'secret6');
      await service.signOut();
      expect(await service.restoreLocalUser(), isNull);
    });
  });
}
