import 'package:flutter/material.dart';

import '../../core/responsive/responsive.dart';
import '../../core/theme/app_colors.dart';
import 'app_icon.dart';

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size,
    this.showDot = false,
    this.background,
  });

  final AppIconName icon;
  final VoidCallback onTap;
  final double? size;
  final bool showDot;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final dimension = size ?? context.r(30);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: dimension,
        height: dimension,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: background ?? const Color(0x14FFFFFF),
                border: Border.all(color: Colors.transparent),
              ),
              child: Center(
                child: AppIcon(
                  icon,
                  size: context.r(17),
                  color: AppColors.inkSecondary,
                ),
              ),
            ),
            if (showDot)
              Positioned(
                top: context.r(1),
                right: context.r(1),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.green,
                    border: Border.all(
                      color: AppColors.ground,
                      width: context.r(1.5),
                    ),
                  ),
                  child: SizedBox(width: context.r(7), height: context.r(7)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
