import 'package:flutter/material.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_icon_button.dart';
import '../../../../shared/widgets/app_icon.dart';

class CinemaHeader extends StatelessWidget {
  const CinemaHeader({
    super.key,
    required this.activeIndex,
    required this.onSelect,
    required this.onMore,
  });

  final int activeIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onMore;

  static const _labels = ['今天', '朋友圈', '日记', '他'];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.h(0.032),
          vertical: AppSpacing.sm(context),
        ),
        child: Row(
          children: [
            _Location(),
            Expanded(
              child: _Nav(
                activeIndex: activeIndex,
                labels: _labels,
                onSelect: onSelect,
              ),
            ),
            _Meta(onMore: onMore),
          ],
        ),
      ),
    );
  }
}

class _Location extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: const BoxDecoration(
            color: AppColors.green,
            shape: BoxShape.circle,
          ),
          child: SizedBox(width: context.r(7), height: context.r(7)),
        ),
        SizedBox(width: AppSpacing.sm(context)),
        Text(
          '栖湾 · 旧书店',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.caption(context),
        ),
      ],
    );
  }
}

class _Nav extends StatelessWidget {
  const _Nav({
    required this.activeIndex,
    required this.labels,
    required this.onSelect,
  });

  final int activeIndex;
  final List<String> labels;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          if (i > 0) SizedBox(width: context.r(26)),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onSelect(i),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xs(context)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    labels[i],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.nav(context).copyWith(
                      color: i == activeIndex
                          ? AppColors.ink
                          : AppColors.inkFaint,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xxs(context)),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: i == activeIndex
                          ? AppColors.tint
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox(width: context.r(4), height: context.r(4)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.onMore});

  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppIconButton(icon: AppIconName.search, onTap: () {}),
        SizedBox(width: AppSpacing.xs(context)),
        AppIconButton(icon: AppIconName.camera, onTap: () {}),
        SizedBox(width: AppSpacing.sm(context)),
        Text('17:42', style: AppTextStyles.caption(context)),
        SizedBox(width: AppSpacing.sm(context)),
        Text('雨 1.7°C', style: AppTextStyles.caption(context)),
        SizedBox(width: AppSpacing.sm(context)),
        AppIconButton(icon: AppIconName.more, onTap: onMore),
      ],
    );
  }
}
