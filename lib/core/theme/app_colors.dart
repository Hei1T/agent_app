import 'package:flutter/material.dart';

/// 全局颜色令牌。业务代码不直接写 Color(0x...)。
abstract final class AppColors {
  static const ground = Color(0xFF0B0908);
  static const surface = Color(0xFF15100E);
  static const surfaceRaised = Color(0xFF211814);
  static const surfaceGlass = Color(0xCC1B1411);

  static const ink = Color(0xFFF6F1E9);
  static const inkSecondary = Color(0xB3F6F1E9);
  static const inkMuted = Color(0x8AF6F1E9);
  static const inkFaint = Color(0x5CF6F1E9);

  static const tint = Color(0xFFFFB183);
  static const tintStrong = Color(0xFFFF8F56);
  static const tintSoft = Color(0x1AFFB183);
  static const tintBorder = Color(0x4DFFB183);

  static const green = Color(0xFF34C759);
  static const danger = Color(0xFFFF6B5E);

  static const border = Color(0x1AFFFFFF);
  static const borderStrong = Color(0x33FFFFFF);
  static const divider = Color(0x0FFFFFFF);

  static const scrimTop = Color(0xBD080605);
  static const scrimBottom = Color(0xF5080605);

  static const photoOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xBD080605), Color(0x1A080605), Color(0xD1080605)],
    stops: [0, 0.45, 1],
  );

  static const warmGlow = RadialGradient(
    center: Alignment.topRight,
    radius: 0.9,
    colors: [Color(0x1FFFB183), Color(0x00FFB183)],
  );
}
