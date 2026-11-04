import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/responsive/responsive.dart';
import 'app_dock_item.dart';
import 'app_icon.dart';

class SideDockItem {
  const SideDockItem({
    required this.label,
    required this.icon,
    this.dot = false,
  });

  final String label;
  final AppIconName icon;
  final bool dot;
}

const sideDockItems = [
  SideDockItem(label: '今天', icon: AppIconName.sun),
  SideDockItem(label: '朋友圈', icon: AppIconName.moments),
  SideDockItem(label: '日记', icon: AppIconName.diary),
  SideDockItem(label: '他', icon: AppIconName.person),
  SideDockItem(label: '对话', icon: AppIconName.chat, dot: true),
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
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
        child: DecoratedBox(
          key: const Key('phone_side_dock'),
          decoration: BoxDecoration(
            color: const Color(0x521B1411),
            borderRadius: radius,
            border: Border.all(color: const Color(0x2BFFFFFF)),
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
                  AppDockItem(
                    label: sideDockItems[i].label,
                    icon: sideDockItems[i].icon,
                    dot: sideDockItems[i].dot,
                    height: 46,
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
