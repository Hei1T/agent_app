import 'package:flutter/widgets.dart';

import '../responsive/responsive.dart';

/// 间距 / 圆角令牌，内部按屏幕缩放。
abstract final class AppSpacing {
  static double xxs(BuildContext c) => c.r(3);
  static double xs(BuildContext c) => c.r(5);
  static double sm(BuildContext c) => c.r(8);
  static double md(BuildContext c) => c.r(12);
  static double lg(BuildContext c) => c.r(16);
  static double xl(BuildContext c) => c.r(22);
  static double xxl(BuildContext c) => c.r(30);

  static double pageH(BuildContext c) => c.r(c.isPhone ? 14 : 16);
  static double headerTop(BuildContext c) => c.r(c.isPhone ? 8 : 14);
  static double dockHeight(BuildContext c) => c.r(64);
}

abstract final class AppRadius {
  static double sm(BuildContext c) => c.r(9);
  static double md(BuildContext c) => c.r(14);
  static double lg(BuildContext c) => c.r(18);
  static double xl(BuildContext c) => c.r(22);
  static double pill(BuildContext c) => c.r(999);
}
