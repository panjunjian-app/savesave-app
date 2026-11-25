import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:savesave/core/api_client.dart';
import 'package:savesave/data/database.dart';
import 'package:savesave/domain/services/auth_service.dart';
import 'package:savesave/domain/services/token_store.dart';

/// 可控的云端认证 mock（实现 AuthRemote 抽象，不发起任何网络请求）。
///
/// v3 起密码校验发生在服务端：本 mock 等价模拟「服务端 users 表 + 会话签发」。
class _FakeAuthRemote implements AuthRemote {
  _FakeAuthRemote({this.serverUid = 'u-cloud-0001'});

  /// 服务端生成的云端 uid（注册时下发）。
  final String serverUid;

  /// 模拟服务端 users 表：email → password。
  final Map<String, String> users = <String, String>{};

  int logoutCalls = 0;

  AuthSessionResponse _sessionFor(String email) => AuthSessionResponse(
        userId: serverUid,
        email: email,
        nickname: '云端用户',
        accessToken: 'access-token-for-$email',
        refreshToken: 'refresh-token-for-$email',
      );

  @override
  Future<AuthSessionResponse> register({
    required String email,
    required String password,
    String? nickname,
  }) async {
    if (users.containsKey(email)) {
      throw const ApiFailure('EMAIL_EXISTS', '该邮箱已注册，请直接登录');
    }
    users[email] = password;
    return _sessionFor(email);
  }

  @override
  Future<AuthSessionResponse> login({
    required String email,
    required String password,
  }) async {
    if (users[email] != password) {
      throw const ApiFailure('INVALID_CREDENTIALS', '邮箱或密码不正确');
    }
    return _sessionFor(email);
  }

  @override
  Future<AuthSessionResponse?> restore() async => null;

  @override
  Future<void> logout() async {
    logoutCalls++;
  }
}

/// 内存版 SecureKeyValueStore（等价 secure storage / localStorage）。
class _InMemorySecureStore implements SecureKeyValueStore {
  final Map<String, String> values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);

  @override
  Future<void> clear() async => values.clear();
}

/// 邮箱注册/登录/游客升级测试（内存 SQLite + 内存 SharedPreferences +
/// mock 云端认证服务）。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late AuthService service;
  late _FakeAuthRemote remote;
  late TokenStore tokenStore;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    db = AppDatabase.forTesting(NativeDatabase.memory());
    remote = _FakeAuthRemote(serverUid: 'u-cloud-0001');
    tokenStore = TokenStore(storage: _InMemorySecureStore());
    service = AuthService(
      db,
      remote: remote,
      tokenStore: tokenStore,
      prefs: prefs,
    );
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

    test('密码校验：至少 8 位、最多 64 位（S2 服务端同规则）', () {
      expect(AuthService.validatePassword('12345678'), isNull);
      expect(AuthService.validatePassword('1234567'), isNotNull);
      expect(AuthService.validatePassword(''), isNotNull);
      expect(AuthService.validatePassword('x' * 65), isNotNull);
    });
  });

  group('AuthService 邮箱注册与登录', () {
    test('注册成功并自动登录云端会话', () async {
      final user = await service.signUpWithEmail(
        email: 'Pan@Test.COM',
        password: 'secret6x',
      );
      expect(user.loginType, 'email');
      expect(user.email, 'pan@test.com'); // 存库统一小写
      // v3：密码不再落本地库（服务端 PBKDF2 校验，本地无任何哈希副本）
      expect(user.passwordHash, isNull);
      expect(user.id, remote.serverUid); // 云端 uid 接管本地镜像行

      // 会话落 secure storage：access/refresh/uid 三件套齐备
      expect(await tokenStore.readAccessToken(), 'access-token-for-pan@test.com');
      expect(await tokenStore.readRefreshToken(), 'refresh-token-for-pan@test.com');
      expect(await tokenStore.readCloudUid(), remote.serverUid);

      final restored = await service.restoreLocalUser();
      expect(restored?.id, user.id);
    });

    test('重复注册同一邮箱被拒绝（服务端 409 EMAIL_EXISTS）', () async {
      await service.signUpWithEmail(email: 'a@b.com', password: 'secret6x');
      expect(
        () => service.signUpWithEmail(email: 'a@b.com', password: 'other667'),
        throwsA(isA<AuthFailure>()),
      );
    });

    test('注册弱密码被拒绝（客户端与服务端同为 ≥8 位）', () async {
      expect(
        () => service.signUpWithEmail(email: 'a@b.com', password: '123'),
        throwsA(isA<AuthFailure>()),
      );
    });

    test('正确密码登录成功', () async {
      await service.signUpWithEmail(email: 'a@b.com', password: 'secret6x');
      final user = await service.signInWithEmail(
        email: 'A@B.com',
        password: 'secret6x',
      );
      expect(user.email, 'a@b.com');
    });

    test('错误密码登录失败（服务端统一文案）', () async {
      await service.signUpWithEmail(email: 'a@b.com', password: 'secret6x');
      expect(
        () => service.signInWithEmail(email: 'a@b.com', password: 'wrong666'),
        throwsA(
          isA<AuthFailure>().having(
            (error) => error.message,
            'message',
            '邮箱或密码不正确',
          ),
        ),
      );
    });

    test('未注册邮箱登录被拒绝', () async {
      expect(
        () => service.signInWithEmail(email: 'nobody@b.com', password: 'secret6x'),
        throwsA(isA<AuthFailure>()),
      );
    });

    test('游客注册后升级为邮箱账号（云端 uid 接管，游客数据由迁移器继承）', () async {
      final guest = await service.signInAsGuest();
      expect(guest.loginType, 'guest');

      final upgraded = await service.signUpWithEmail(
        email: 'a@b.com',
        password: 'secret6x',
      );
      // v3：云端 uid 由服务端生成，不再复用游客本地 id；
      // 游客数据的继承交由 AccountMigrator（重写 user_id 归属）。
      expect(upgraded.id, remote.serverUid);
      expect(upgraded.loginType, 'email');
      // 本地游客镜像行仍在（迁移红线：不删本地数据）
      expect(await db.userDao.findById(guest.id), isNotNull);
    });

    test('登出后 restoreLocalUser 返回 null', () async {
      await service.signUpWithEmail(email: 'a@b.com', password: 'secret6x');
      await service.signOut();

      expect(await tokenStore.readCloudUid(), isNull);
      expect(remote.logoutCalls, 1);
      expect(await service.restoreLocalUser(), isNull);
    });
  });
}
