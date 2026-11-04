import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/responsive/responsive.dart';
import '../../core/theme/app_spacing.dart';
import 'app_dock_item.dart';
import 'app_icon.dart';

class DockItemData {
  const DockItemData({
    required this.label,
    required this.icon,
    this.dot = false,
  });

  final String label;
  final AppIconName icon;
  final bool dot;
}

const dockItems = [
  DockItemData(label: '今天', icon: AppIconName.sun),
  DockItemData(label: '朋友圈', icon: AppIconName.moments),
  DockItemData(label: '日记', icon: AppIconName.diary),
  DockItemData(label: '他', icon: AppIconName.person),
  DockItemData(label: '对话', icon: AppIconName.chat, dot: true),
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
              colors: [Color(0x521B1411), Color(0x300D0A09)],
            ),
            borderRadius: radius,
            border: Border.all(color: const Color(0x2BFFFFFF)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x5C000000),
                blurRadius: 42,
                offset: Offset(0, 20),
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
                  AppDockItem(
                    label: dockItems[i].label,
                    icon: dockItems[i].icon,
                    dot: dockItems[i].dot,
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
