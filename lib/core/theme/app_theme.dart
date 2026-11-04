import 'package:flutter/material.dart';

import 'app_colors.dart';

ThemeData buildAppTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    textTheme: base.textTheme.apply(
      fontFamily: 'PingFangSC',
      fontFamilyFallback: const ['NotoSansSC'],
    ),
    primaryTextTheme: base.primaryTextTheme.apply(fontFamily: 'NotoSansSC'),
    scaffoldBackgroundColor: AppColors.ground,
    canvasColor: AppColors.ground,
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.tint,
      secondary: AppColors.tintStrong,
      surface: AppColors.surface,
      onSurface: AppColors.ink,
      error: AppColors.danger,
    ),
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    dividerColor: AppColors.divider,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      foregroundColor: AppColors.ink,
    ),
  );
}
