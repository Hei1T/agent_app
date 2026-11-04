import 'package:flutter/foundation.dart';

abstract final class ApiEndpoints {
  static String get baseUrl {
    const configured = String.fromEnvironment('API_BASE_URL');
    if (configured.isNotEmpty) return configured;
    if (kIsWeb) return 'http://127.0.0.1:3000/api/v1';
    if (defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:3000/api/v1';
    return 'http://127.0.0.1:3000/api/v1';
  }

  static const login = '/auth/login';
  static const register = '/auth/register';
  static const life = '/core/life';
  static const feed = '/core/life/feed';
  static const chat = '/chat';
  static const credits = '/credits/balance';
}
