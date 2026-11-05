import 'package:flutter/foundation.dart';

/// /api/v1 路径常量。
///
/// App 只请求契约路径；旧 /core 透传路径仅作为过渡期兼容保留，
/// 新代码禁止使用（见 docs/API_CONTRACT_V1.md §11 迁移顺序）。
abstract final class ApiEndpoints {
  static String get baseUrl {
    const configured = String.fromEnvironment('API_BASE_URL');
    if (configured.isNotEmpty) {
      return configured;
    }
    if (kIsWeb) {
      return 'http://127.0.0.1:3000/api/v1';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000/api/v1';
    }
    return 'http://127.0.0.1:3000/api/v1';
  }

  // ---- API Contract v1 ----

  static const authLogin = '/auth/login';
  static const authRegister = '/auth/register';
  static const authMe = '/auth/me';

  static const companionState = '/companion/state';
  static const companionMoments = '/companion/moments';
  static const companionDiary = '/companion/diary';

  static const creditsBalance = '/credits/balance';
  static const chat = '/chat';

  /// v1 扩展：POST /companion/moments/:id/like。
  static String momentLike(String momentId) =>
      '$companionMoments/${Uri.encodeComponent(momentId)}/like';

  /// v1 扩展：POST /companion/moments/:id/comments。
  static String momentComments(String momentId) =>
      '$companionMoments/${Uri.encodeComponent(momentId)}/comments';

  // ---- 旧路径：只读兼容，返回同一份契约数据 ----
  // 保留一个客户端版本周期，App 新代码不要再引用。

  @Deprecated('改用 ApiEndpoints.companionState（/companion/state）')
  static const life = '/core/life';

  @Deprecated('改用 ApiEndpoints.companionMoments（/companion/moments）')
  static const feed = '/core/life/feed';

  @Deprecated('改用 ApiEndpoints.authLogin')
  static const login = authLogin;

  @Deprecated('改用 ApiEndpoints.authRegister')
  static const register = authRegister;

  @Deprecated('改用 ApiEndpoints.creditsBalance')
  static const credits = creditsBalance;
}
