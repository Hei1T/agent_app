import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../network/api_endpoints.dart';

/// 业务层 WS：GET /api/v1/ws?token=jwt
/// core 事件由 business-api 按账号的 core session 过滤后转发。
class RealtimeService {
  RealtimeService({required this.token, required this.onEvent});

  final String token;
  final void Function(Map<String, dynamic> event) onEvent;

  WebSocket? _socket;
  StreamSubscription<dynamic>? _subscription;
  Timer? _reconnect;
  bool _closed = false;

  Future<void> connect() async {
    if (_closed || _socket != null) return;
    final base = Uri.parse(ApiEndpoints.baseUrl);
    final uri = base.replace(
      scheme: base.scheme == 'https' ? 'wss' : 'ws',
      path: '${base.path}/ws',
      queryParameters: {'token': token},
    );
    try {
      final socket = await WebSocket.connect(uri.toString());
      if (_closed) {
        await socket.close();
        return;
      }
      _socket = socket;
      _subscription = socket.listen(
        _handle,
        onDone: _scheduleReconnect,
        onError: (_) => _scheduleReconnect(),
        cancelOnError: false,
      );
    } catch (_) {
      _scheduleReconnect();
    }
  }

  void _handle(dynamic raw) {
    if (raw is! String) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return;
      // core 握手：hello 带最后 seq；回传 since 跳过历史积压，只收新事件。
      if (decoded['hello'] == true) {
        final seq = decoded['seq'];
        if (seq is int) _socket?.add(jsonEncode({'since': seq}));
        return;
      }
      onEvent(decoded);
    } catch (_) {
      // 单帧解析失败不影响连接。
    }
  }

  void _scheduleReconnect() {
    if (_closed || _reconnect != null) return;
    _reconnect = Timer(const Duration(seconds: 3), () async {
      _reconnect = null;
      await _disposeSocket();
      await connect();
    });
  }

  Future<void> _disposeSocket() async {
    final sub = _subscription;
    _subscription = null;
    await sub?.cancel();
    final socket = _socket;
    _socket = null;
    await socket?.close();
  }

  Future<void> dispose() async {
    _closed = true;
    _reconnect?.cancel();
    _reconnect = null;
    await _disposeSocket();
  }
}
