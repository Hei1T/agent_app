import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/responsive/responsive.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'app_icon.dart';

class DockItemData {
  const DockItemData({required this.label, required this.icon});

  final String label;
  final AppIconName icon;
}

const dockItems = [
  DockItemData(label: '今天', icon: AppIconName.sun),
  DockItemData(label: '朋友圈', icon: AppIconName.moments),
  DockItemData(label: '日记', icon: AppIconName.diary),
  DockItemData(label: '他', icon: AppIconName.person),
  DockItemData(label: '对话', icon: AppIconName.chat),
];

/// 手机竖屏：底部悬浮 dock。
class Dock extends StatelessWidget {
  const Dock({super.key, required this.index, required this.onSelect});

  final int index;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.pill(context));
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
        child: DecoratedBox(
          key: const Key('phone_dock'),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1B1411), Color(0xFF1B1411)],
            ),
            borderRadius: radius,
            border: Border.all(color: const Color(0x2BFFFFFF)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x75000000),
                blurRadius: 46,
                offset: Offset(0, 22),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.r(6),
              vertical: context.r(2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < dockItems.length; i++) ...[
                  if (i > 0) SizedBox(width: context.r(2)),
                  _DockItem(
                    item: dockItems[i],
                    selected: i == index,
                    onTap: () => onSelect(i),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DockItem extends StatelessWidget {
  const _DockItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final DockItemData item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: context.r(46),
        height: context.r(48),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (selected)
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(context.r(12)),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x21FFFFFF), Color(0x0FFFFFFF)],
                  ),
                  border: Border.all(color: Color(0x29FFFFFF)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x3D000000),
                      blurRadius: 14,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const SizedBox.expand(),
              ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  scale: selected ? 1.06 : 1,
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  child: AppIcon(
                    item.icon,
                    size: context.r(18),
                    color: selected ? AppColors.ink : AppColors.inkFaint,
                  ),
                ),
                SizedBox(height: AppSpacing.xxs(context)),
                Text(
                  item.label,
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
          ],
        ),
      ),
    );
  }
}
