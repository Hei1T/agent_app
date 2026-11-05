import 'package:flutter/widgets.dart';

import '../responsive/responsive.dart';
import 'app_colors.dart';

/// 全局文字令牌。业务代码不直接写 fontSize。
abstract final class AppTextStyles {
  static TextStyle micro(BuildContext c) => TextStyle(
    fontSize: c.sp(7.5),
    letterSpacing: 0.1,
    color: AppColors.inkFaint,
    height: 1.35,
  );

  static TextStyle caption(BuildContext c) =>
      TextStyle(fontSize: c.sp(9), color: AppColors.inkMuted, height: 1.45);

  static TextStyle body(BuildContext c) => TextStyle(
    fontSize: c.sp(11),
    color: AppColors.inkSecondary,
    height: 1.65,
  );

  static TextStyle bodyStrong(BuildContext c) => TextStyle(
    fontSize: c.sp(11),
    fontWeight: FontWeight.w500,
    color: AppColors.ink,
    height: 1.5,
  );

  static TextStyle title(BuildContext c) => TextStyle(
    fontSize: c.sp(15),
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
    letterSpacing: -0.2,
    height: 1.25,
  );

  static TextStyle headline(BuildContext c) => TextStyle(
    fontSize: c.sp(26),
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
    letterSpacing: -0.6,
    height: 1.15,
  );

  static TextStyle display(BuildContext c) => TextStyle(
    fontSize: c.sp(c.isWide ? 54 : 40),
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
    letterSpacing: -1.2,
    height: 1.04,
  );

  static TextStyle label(BuildContext c) => TextStyle(
    fontSize: c.sp(8),
    letterSpacing: 1.1,
    color: AppColors.inkFaint,
  );

  static TextStyle nav(BuildContext c) => TextStyle(
    fontSize: c.sp(10.5),
    letterSpacing: 0.8,
    color: AppColors.inkFaint,
  );
}
