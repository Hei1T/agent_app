class ApiException implements Exception {
  const ApiException(
    this.statusCode,
    this.message, {
    this.code,
    this.requestId,
  });

  final int statusCode;
  final String message;

  /// 契约错误码，如 AUTH_REQUIRED / INSUFFICIENT_CREDITS。
  final String? code;

  /// 契约错误响应里的 requestId，便于和后端日志对齐。
  final String? requestId;

  bool get isUnauthorized => statusCode == 401;
  bool get isInsufficientCredits =>
      code == 'INSUFFICIENT_CREDITS' || statusCode == 402;

  @override
  String toString() => message;
}
