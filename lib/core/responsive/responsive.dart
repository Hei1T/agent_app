import 'package:flutter/widgets.dart';

/// 统一响应式换算。业务代码用 context.r / context.sp，不写死像素。
extension ResponsiveX on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
  bool get isPhone => screenWidth < 600;
  bool get isTablet => screenWidth >= 600 && screenWidth < 1000;
  bool get isPortrait => screenHeight >= screenWidth;
  bool get isWide => screenWidth >= 600;

  double get scale {
    final tableDevice = MediaQuery.sizeOf(this).shortestSide >= 600;
    final baseWidth = tableDevice ? 1112.0 : (isPortrait ? 390.0 : 844.0);
    final baseHeight = tableDevice ? 834.0 : (isPortrait ? 844.0 : 390.0);
    final s = (screenWidth / baseWidth).clamp(0.0, screenHeight / baseHeight);
    return s.clamp(0.82, 1.08);
  }

  double r(double base) => base * scale;
  double sp(double base) => base * scale;
  double v(double fraction) => screenHeight * fraction;
  double h(double fraction) => screenWidth * fraction;
}

extension ResponsiveBox on Widget {
  Widget padAll(BuildContext context, double value) =>
      Padding(padding: EdgeInsets.all(context.r(value)), child: this);
}
