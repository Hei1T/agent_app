import 'package:flutter/widgets.dart';

/// 统一响应式换算。业务代码用 context.r / context.sp，不写死像素。
extension ResponsiveX on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
  bool get isPhone => MediaQuery.sizeOf(this).shortestSide < 600;
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

  /// 移动端最小可读字号。设计稿里的 7.5/9/10.5 在真机上过小，
  /// 统一抬到 11pt；普通正文再额外加 1pt，标题只微调。
  double sp(double base) {
    final scaled = base * scale;
    // 平板也保证最小可读字号；手机上再把正文/说明整体放大一档。
    if (scaled < 10.5) return 10.5;
    if (!isPhone) return scaled;
    if (base < 14) return scaled + 1;
    return scaled + 0.5;
  }

  double v(double fraction) => screenHeight * fraction;
  double h(double fraction) => screenWidth * fraction;
}

extension ResponsiveBox on Widget {
  Widget padAll(BuildContext context, double value) =>
      Padding(padding: EdgeInsets.all(context.r(value)), child: this);
}
