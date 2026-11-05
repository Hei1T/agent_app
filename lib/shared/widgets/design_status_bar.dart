import 'package:flutter/material.dart';

import '../../core/responsive/responsive.dart';

/// 设计稿 44px 状态栏。全屏沉浸时自绘，保证内容坐标与 React 390×844 一致。
class DesignStatusBar extends StatelessWidget {
  const DesignStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.r(44),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: context.r(28)),
        child: Row(
          children: [
            Text(
              '9:41',
              style: TextStyle(
                color: const Color(0xFFF7F2EB),
                fontSize: context.sp(13),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.signal_cellular_alt_rounded,
              size: context.r(15),
              color: const Color(0xFFF7F2EB),
            ),
            SizedBox(width: context.r(5)),
            Icon(
              Icons.wifi_rounded,
              size: context.r(16),
              color: const Color(0xFFF7F2EB),
            ),
            SizedBox(width: context.r(5)),
            Icon(
              Icons.battery_full_rounded,
              size: context.r(19),
              color: const Color(0xFFF7F2EB),
            ),
          ],
        ),
      ),
    );
  }
}
