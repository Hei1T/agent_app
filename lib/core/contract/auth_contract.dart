import 'contract_json.dart';

/// 账号信息（/auth/login、/auth/register、/auth/me）。
class AuthAccount {
  const AuthAccount({required this.id, required this.email, this.status});

  final String id;
  final String email;

  /// /auth/me 才返回；login/register 可为 null。
  final String? status;

  factory AuthAccount.fromJson(Map<String, dynamic> json) => AuthAccount(
    id: contractId(json['id']) ?? '',
    email: contractStringOr(json['email'], ''),
    status: contractString(json['status']),
  );
}

/// 登录时后端必须返回的陪伴对象摘要（不含完整 profile）。
class AuthCompanion {
  const AuthCompanion({
    required this.id,
    required this.displayName,
    this.version,
    this.profile,
    this.syncStatus,
  });

  final String id;
  final String displayName;
  final int? version;
  final Map<String, dynamic>? profile;
  final String? syncStatus;

  factory AuthCompanion.fromJson(Map<String, dynamic> json) => AuthCompanion(
    id: contractId(json['id']) ?? '',
    displayName: contractStringOr(json['displayName'], ''),
    version: contractInt(json['version']),
    // 契约字段为 profile；旧后端为 profileJson，过渡期两者都接受。
    profile: contractMap(json['profile']) ?? contractMap(json['profileJson']),
    syncStatus: contractString(json['syncStatus']),
  );
}

/// POST /auth/login、/auth/register 响应。
class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.account,
    this.expiresIn,
    this.companion,
  });

  final String accessToken;

  /// 秒；后端补齐前可为 null。
  final int? expiresIn;
  final AuthAccount account;
  final AuthCompanion? companion;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final accountJson =
        contractMap(json['account']) ?? const <String, dynamic>{};
    final companionJson = contractMap(json['companion']);
    return AuthSession(
      accessToken: contractStringOr(json['accessToken'], ''),
      expiresIn: contractInt(json['expiresIn']),
      account: AuthAccount.fromJson(accountJson),
      companion: companionJson == null
          ? null
          : AuthCompanion.fromJson(companionJson),
    );
  }
}

/// GET /auth/me 响应。
class AuthMe {
  const AuthMe({required this.account, this.companion});

  final AuthAccount account;
  final AuthCompanion? companion;

  factory AuthMe.fromJson(Map<String, dynamic> json) {
    // 契约是 { account, companion }；旧后端把账号字段平铺在顶层。
    final accountJson = contractMap(json['account']) ?? json;
    final companionJson = contractMap(json['companion']);
    return AuthMe(
      account: AuthAccount.fromJson(accountJson),
      companion: companionJson == null
          ? null
          : AuthCompanion.fromJson(companionJson),
    );
  }
}
