import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../contract/auth_contract.dart';
import '../network/api_exception.dart';
import '../providers/app_providers.dart';

export '../providers/app_providers.dart' show apiProvider;

class AuthState {
  const AuthState({
    required this.loading,
    this.token,
    this.email,
    this.companionName,
    this.error,
  });

  final bool loading;
  final String? token;
  final String? email;

  /// /auth/login 或 /auth/me 返回的陪伴对象名字，仅作首屏兜底。
  final String? companionName;
  final String? error;

  bool get authenticated => token != null && token!.isNotEmpty;
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this.api, {AuthState? initial, bool restore = true})
    : super(initial ?? const AuthState(loading: true)) {
    api.onUnauthorized = _onUnauthorized;
    if (restore) unawaited(_restore());
  }

  final ApiClient api;

  /// 启动流程：
  /// 1. 读安全存储里的 token，先放行进入 App（不等网络）；
  /// 2. 调 /auth/me 校验 token 与陪伴对象；
  /// 3. 401 清 token 回登录；网络错误保留本地登录态（后端未就绪/离线）。
  Future<void> _restore() async {
    String? token;
    String? email;
    try {
      token = await api.storage.readToken();
      email = await api.storage.readEmail();
    } catch (_) {
      token = null;
      email = null;
    }
    if (!mounted) return;
    if (token == null || token.isEmpty) {
      state = const AuthState(loading: false);
      return;
    }
    api.token = token;
    state = AuthState(loading: false, token: token, email: email);
    try {
      final me = await api.me();
      if (!mounted) return;
      state = AuthState(
        loading: false,
        token: token,
        email: me.account.email.isEmpty ? email : me.account.email,
        companionName: me.companion?.displayName,
      );
    } on ApiException catch (error) {
      if (error.isUnauthorized) {
        await _clearSession();
      }
      // 其他错误（网络 / CORE_UNAVAILABLE）不把已登录用户踢回登录页。
    } catch (_) {
      // 启动校验失败不应阻塞正在使用的会话；下一次请求仍会暴露 401。
    }
  }

  Future<void> login(String email, String password) async {
    state = const AuthState(loading: true);
    try {
      final session = await api.login(email.trim(), password);
      await api.storage.save(session.accessToken, session.account.email);
      if (!mounted) return;
      state = _stateFrom(session, fallbackEmail: email.trim());
    } catch (error) {
      if (mounted) state = AuthState(loading: false, error: _messageOf(error));
    }
  }

  Future<void> register(String email, String password) async {
    state = const AuthState(loading: true);
    try {
      final session = await api.register(email.trim(), password);
      await api.storage.save(session.accessToken, session.account.email);
      if (!mounted) return;
      state = _stateFrom(session, fallbackEmail: email.trim());
    } catch (error) {
      if (mounted) state = AuthState(loading: false, error: _messageOf(error));
    }
  }

  Future<void> logout() async {
    await _clearSession();
  }

  AuthState _stateFrom(AuthSession session, {required String fallbackEmail}) {
    return AuthState(
      loading: false,
      token: session.accessToken,
      email: session.account.email.isEmpty
          ? fallbackEmail
          : session.account.email,
      companionName: session.companion?.displayName,
    );
  }

  Future<void> _clearSession() async {
    api.token = null;
    try {
      await api.storage.clear();
    } catch (_) {
      // 安全存储清理失败不阻塞退出登录。
    }
    if (mounted) state = const AuthState(loading: false);
  }

  void _onUnauthorized() {
    if (!state.authenticated) return;
    unawaited(_clearSession());
  }

  String _messageOf(Object error) =>
      error is ApiException ? error.message : error.toString();
}

final authProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(ref.read(apiProvider)),
);
