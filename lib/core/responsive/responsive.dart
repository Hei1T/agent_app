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

  /// 移动端可读字号。设计稿 7.5/9/10.5 在真机上过小，
  /// 手机统一放大 18% 并保证至少 12pt；大标题只微调。
  double sp(double base) {
    final scaled = base * scale;
    if (base >= 20) return scaled + 0.5;
    if (!isPhone) return scaled < 10.5 ? 10.5 : scaled;
    final boosted = scaled * 1.18 + 0.8;
    return boosted < 12 ? 12 : boosted;
  }

  double v(double fraction) => screenHeight * fraction;
  double h(double fraction) => screenWidth * fraction;
}

extension ResponsiveBox on Widget {
  Widget padAll(BuildContext context, double value) =>
      Padding(padding: EdgeInsets.all(context.r(value)), child: this);
}
