import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  TokenStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();
  final FlutterSecureStorage _storage;
  static const _tokenKey = 'benben_access_token';
  static const _emailKey = 'benben_email';
  Future<String?> readToken() => _storage.read(key: _tokenKey);
  Future<String?> readEmail() => _storage.read(key: _emailKey);
  Future<void> save(String token, String email) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _emailKey, value: email);
  }

  Future<void> clear() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _emailKey);
  }
}
