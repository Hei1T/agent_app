import 'package:flutter/material.dart';

import '../../core/responsive/responsive.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'app_icon.dart';

class SideDockItem {
  const SideDockItem({required this.label, required this.icon});

  final String label;
  final AppIconName icon;
}

const sideDockItems = [
  SideDockItem(label: '今天', icon: AppIconName.sun),
  SideDockItem(label: '朋友圈', icon: AppIconName.moments),
  SideDockItem(label: '日记', icon: AppIconName.diary),
  SideDockItem(label: '他', icon: AppIconName.person),
  SideDockItem(label: '对话', icon: AppIconName.chat),
];

class SideDock extends StatelessWidget {
  const SideDock({super.key, required this.index, required this.onSelect});

  final int index;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(context.r(27));
    return ClipRRect(
      borderRadius: radius,
      child: DecoratedBox(
        key: const Key('phone_side_dock'),
        decoration: BoxDecoration(
          color: const Color(0xF21B1411),
          borderRadius: radius,
          border: Border.all(color: AppColors.border),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.r(4),
            vertical: context.r(6),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < sideDockItems.length; i++) ...[
                if (i > 0) SizedBox(height: context.r(2)),
                _DockItem(
                  item: sideDockItems[i],
                  selected: i == index,
                  onTap: () => onSelect(i),
                ),
              ],
            ],
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

  final SideDockItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(context.r(12));
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: selected
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x33FFFFFF), Color(0x0FFFFFFF)],
                )
              : null,
          border: selected ? Border.all(color: const Color(0x29FFFFFF)) : null,
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x3D000000),
                    blurRadius: 14,
                    offset: Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: SizedBox(
          width: context.r(46),
          height: context.r(46),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppIcon(
                item.icon,
                size: context.r(18),
                color: selected ? AppColors.ink : AppColors.inkFaint,
              ),
              SizedBox(height: context.r(2)),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.micro(context).copyWith(
                  letterSpacing: 0.02,
                  color: selected ? AppColors.ink : AppColors.inkFaint,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
