import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// 本地系统通知：App 进程还活着时，主动消息可以落到 Android 通知栏。
/// App 被系统杀掉后 WS 不存在，必须由后端 FCM/APNs 推送。
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static final StreamController<void> _taps =
      StreamController<void>.broadcast();
  static bool _ready = false;

  static Stream<void> get taps => _taps.stream;

  static Future<void> initialize() async {
    try {
      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
        macOS: DarwinInitializationSettings(),
      );
      await _plugin.initialize(
        settings: settings,
        onDidReceiveNotificationResponse: (response) {
          if (response.payload == 'chat') _taps.add(null);
        },
      );
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await android?.createNotificationChannel(
        const AndroidNotificationChannel(
          'proactive_messages',
          '主动消息',
          description: '他主动发来的消息',
          importance: Importance.high,
        ),
      );
      await android?.requestNotificationsPermission();
      _ready = true;
    } catch (error) {
      debugPrint('NotificationService init failed: $error');
    }
  }

  static String _plainText(String text) {
    final withoutImages = text.replaceAll(
      RegExp(r'!\[[^\]]*\]\([^)]*\)'),
      '发来一张照片',
    );
    return withoutImages.trim();
  }

  static Future<void> showProactive(String text) async {
    if (!_ready) return;
    final body = _plainText(text);
    if (body.isEmpty) return;
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'proactive_messages',
        '主动消息',
        channelDescription: '他主动发来的消息',
        importance: Importance.high,
        priority: Priority.high,
        category: AndroidNotificationCategory.message,
        styleInformation: BigTextStyleInformation(body),
      ),
      iOS: const DarwinNotificationDetails(),
      macOS: const DarwinNotificationDetails(),
    );
    await _plugin.show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(1 << 31),
      title: '笨笨',
      body: body,
      notificationDetails: details,
      payload: 'chat',
    );
  }
}
