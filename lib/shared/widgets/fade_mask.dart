import 'package:flutter/material.dart';

/// 轻量占位：列表不再每帧重算 ShaderMask。
class FadeMask extends StatelessWidget {
  const FadeMask({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}
