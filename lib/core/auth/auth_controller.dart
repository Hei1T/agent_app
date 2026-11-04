import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';

class AuthState {
  const AuthState({required this.loading, this.token, this.email, this.error});
  final bool loading;
  final String? token;
  final String? email;
  final String? error;
  bool get authenticated => token != null && token!.isNotEmpty;
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this.api, {AuthState? initial, bool restore = true})
      : super(initial ?? const AuthState(loading: true)) {
    if (restore) _restore();
  }

  final ApiClient api;

  Future<void> _restore() async {
    final token = await api.storage.readToken();
    final email = await api.storage.readEmail();
    if (token == null || token.isEmpty) {
      state = const AuthState(loading: false);
      return;
    }
    api.token = token;
    state = AuthState(loading: false, token: token, email: email);
  }

  Future<void> login(String email, String password) async {
    state = const AuthState(loading: true);
    try {
      final result = await api.login(email.trim(), password);
      await api.storage.save(result.token, result.email);
      state = AuthState(loading: false, token: result.token, email: result.email);
    } catch (error) {
      state = AuthState(loading: false, error: error.toString());
    }
  }

  Future<void> register(String email, String password) async {
    state = const AuthState(loading: true);
    try {
      final result = await api.register(email.trim(), password);
      await api.storage.save(result.token, result.email);
      state = AuthState(loading: false, token: result.token, email: result.email);
    } catch (error) {
      state = AuthState(loading: false, error: error.toString());
    }
  }

  Future<void> logout() async {
    await api.storage.clear();
    api.token = null;
    state = const AuthState(loading: false);
  }
}

final apiProvider = Provider<ApiClient>((ref) => ApiClient());
final authProvider = StateNotifierProvider<AuthController, AuthState>((ref) => AuthController(ref.read(apiProvider)));
final lifeProvider = FutureProvider.autoDispose<LifeSnapshot>((ref) async => ref.read(apiProvider).life());
final feedProvider = FutureProvider.autoDispose<List<RemoteMoment>>((ref) async => ref.read(apiProvider).feed());
final creditsProvider = FutureProvider.autoDispose<CreditBalance>((ref) async => ref.read(apiProvider).credits());
