import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_controller.dart';
import '../providers/app_providers.dart';
import 'realtime_service.dart';

/// App 生命周期内维持业务层 WS；事件到达后刷新只读契约 provider。
class RealtimeBridge extends ConsumerStatefulWidget {
  const RealtimeBridge({super.key});

  @override
  ConsumerState<RealtimeBridge> createState() => _RealtimeBridgeState();
}

class _RealtimeBridgeState extends ConsumerState<RealtimeBridge> {
  RealtimeService? _service;
  String? _token;
  Timer? _debounce;

  @override
  Widget build(BuildContext context) {
    final enabled = ref.watch(realtimeEnabledProvider);
    final token = ref.watch(authProvider.select((state) => state.token));
    if (!enabled) {
      _stop();
      return const SizedBox.shrink();
    }
    if (token != _token) {
      _stop();
      _token = token;
      if (token != null && token.isNotEmpty) _start(token);
    }
    return const SizedBox.shrink();
  }

  void _start(String token) {
    final service = RealtimeService(token: token, onEvent: _onEvent);
    _service = service;
    unawaited(service.connect());
  }

  void _stop() {
    _debounce?.cancel();
    _debounce = null;
    final service = _service;
    _service = null;
    if (service != null) unawaited(service.dispose());
  }

  void _onEvent(Map<String, dynamic> frame) {
    // 连接级错误帧不触发刷新。
    if (frame['error'] != null) return;
    if (_debounce?.isActive ?? false) return;
    _debounce = Timer(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      ref.invalidate(companionStateProvider);
      ref.invalidate(momentsProvider);
      ref.invalidate(diaryProvider);
    });
  }

  @override
  void dispose() {
    _stop();
    super.dispose();
  }
}
