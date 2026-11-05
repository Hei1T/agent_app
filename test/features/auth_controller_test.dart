import 'package:benben_app/core/api/api_client.dart';
import 'package:benben_app/core/auth/auth_controller.dart';
import 'package:benben_app/core/contract/auth_contract.dart';
import 'package:benben_app/core/network/api_exception.dart';
import 'package:benben_app/core/storage/token_storage.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryStorage extends TokenStorage {
  _MemoryStorage({this.token, this.email});

  String? token;
  String? email;

  @override
  Future<String?> readToken() async => token;

  @override
  Future<String?> readEmail() async => email;

  @override
  Future<void> save(String token, String email) async {
    this.token = token;
    this.email = email;
  }

  @override
  Future<void> clear() async {
    token = null;
    email = null;
  }
}

class _FakeAuthApi extends ApiClient {
  _FakeAuthApi(this.memory, {this.meResult, this.meError})
    : super(storage: memory);

  final _MemoryStorage memory;
  final AuthMe? meResult;
  final Object? meError;

  @override
  Future<AuthMe> me() async {
    final error = meError;
    if (error != null) throw error;
    return meResult!;
  }
}

Future<void> _settle() async {
  for (var i = 0; i < 5; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

AuthMe _me() => AuthMe.fromJson({
  'account': {'id': 'acc_1', 'email': 'demo@benben.local', 'status': 'active'},
  'companion': {'id': 'cmp_1', 'displayName': '笨笨'},
});

void main() {
  test(
    'startup validates token with /auth/me and caches companion name',
    () async {
      final memory = _MemoryStorage(token: 'jwt', email: 'demo@benben.local');
      final api = _FakeAuthApi(memory, meResult: _me());
      final controller = AuthController(api, restore: true);
      addTearDown(controller.dispose);

      await _settle();
      expect(controller.state.loading, isFalse);
      expect(controller.state.token, 'jwt');
      expect(controller.state.companionName, '笨笨');
      expect(api.token, 'jwt');
    },
  );

  test('startup 401 clears token and returns to login state', () async {
    final memory = _MemoryStorage(token: 'expired', email: 'demo@benben.local');
    final api = _FakeAuthApi(
      memory,
      meError: const ApiException(401, '登录已过期', code: 'AUTH_REQUIRED'),
    );
    final controller = AuthController(api, restore: true);
    addTearDown(controller.dispose);

    await _settle();
    expect(controller.state.authenticated, isFalse);
    expect(controller.state.loading, isFalse);
    expect(memory.token, isNull);
    expect(api.token, isNull);
  });

  test('startup network errors keep the local session', () async {
    final memory = _MemoryStorage(token: 'jwt', email: 'demo@benben.local');
    final api = _FakeAuthApi(
      memory,
      meError: const ApiException(0, '网络连接失败，请检查网络'),
    );
    final controller = AuthController(api, restore: true);
    addTearDown(controller.dispose);

    await _settle();
    expect(controller.state.authenticated, isTrue);
    expect(controller.state.token, 'jwt');
    expect(memory.token, 'jwt');
  });

  test('no stored token starts unauthenticated', () async {
    final memory = _MemoryStorage();
    final api = _FakeAuthApi(memory);
    final controller = AuthController(api, restore: true);
    addTearDown(controller.dispose);

    await _settle();
    expect(controller.state.loading, isFalse);
    expect(controller.state.authenticated, isFalse);
  });
}
