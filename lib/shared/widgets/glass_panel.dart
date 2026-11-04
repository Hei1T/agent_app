import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.blur = false,
    this.background,
  });

  final Widget child;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final bool blur;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppRadius.lg(context));
    final surface = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        color: background ?? AppColors.surfaceGlass,
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: padding ?? EdgeInsets.all(AppSpacing.md(context)),
        child: child,
      ),
    );
    return ClipRRect(borderRadius: radius, child: surface);
  }
}
