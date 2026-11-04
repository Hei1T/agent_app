import 'package:flutter/material.dart';

import '../../core/responsive/responsive.dart';

/// 手机页面：悬浮 header + 从 header 下方穿过的滚动内容。
class PhonePage extends StatelessWidget {
  const PhonePage({super.key, required this.header, required this.child});

  final Widget header;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          Positioned.fill(child: child),
          Positioned(
            top: context.r(8),
            left: context.r(14),
            right: context.r(12),
            child: RepaintBoundary(child: header),
          ),
        ],
      ),
    );
  }
}
