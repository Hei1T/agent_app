import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 竖屏共享输入栏 -> ChatView 的文本出口。
final chatOutboxProvider = StateProvider<String?>((ref) => null);
