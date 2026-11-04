import 'package:flutter/material.dart';

import '../../core/responsive/responsive.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'app_icon.dart';

/// 手机 Dock / 横屏侧边 Dock 共用的单项。
class AppDockItem extends StatelessWidget {
  const AppDockItem({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.dot = false,
    this.height = 48,
  });

  final String label;
  final AppIconName icon;
  final bool selected;
  final VoidCallback onTap;
  final bool dot;
  final double height;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: context.r(46),
        height: context.r(height),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  scale: selected ? 1.06 : 1,
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  child: AppIcon(
                    icon,
                    size: context.r(18),
                    color: selected ? AppColors.ink : AppColors.inkFaint,
                  ),
                ),
                SizedBox(height: context.r(2)),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.micro(context).copyWith(
                    fontSize: context.sp(9.5),
                    letterSpacing: 0.02,
                    color: selected ? AppColors.ink : AppColors.inkFaint,
                  ),
                ),
              ],
            ),
            if (dot)
              Positioned(
                top: context.r(7),
                right: context.r(7),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.green,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF1B1411),
                      width: context.r(2),
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
