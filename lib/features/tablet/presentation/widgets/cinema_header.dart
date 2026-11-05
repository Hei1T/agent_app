import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/contract/contract_format.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_icon.dart';
import '../../../../shared/widgets/app_icon_button.dart';

class CinemaHeader extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(companionStateProvider).valueOrNull;
    final place = state?.companion.place?.name ?? '';
    final world = state?.world;
    final clock = world?.clockLabel ?? '';
    final weather = [
      world?.weather ?? '',
      contractTemperatureLabel(world?.temperatureC) ?? '',
    ].where((part) => part.isNotEmpty).join(' ');
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.h(0.032),
          vertical: AppSpacing.sm(context),
        ),
        child: Row(
          children: [
            _Location(place: place),
            Expanded(
              child: _Nav(
                activeIndex: activeIndex,
                labels: _labels,
                onSelect: onSelect,
              ),
            ),
            _Meta(clock: clock, weather: weather, onMore: onMore),
          ],
        ),
      ),
    );
  }
}

class _Location extends StatelessWidget {
  const _Location({required this.place});

  final String place;

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
          place.isEmpty ? '栖湾' : '栖湾 · $place',
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
  const _Meta({
    required this.clock,
    required this.weather,
    required this.onMore,
  });

  final String clock;
  final String weather;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppIconButton(icon: AppIconName.search, onTap: () {}),
        SizedBox(width: AppSpacing.xs(context)),
        AppIconButton(icon: AppIconName.camera, onTap: () {}),
        if (clock.isNotEmpty) ...[
          SizedBox(width: AppSpacing.sm(context)),
          Text(clock, maxLines: 1, style: AppTextStyles.caption(context)),
        ],
        if (weather.isNotEmpty) ...[
          SizedBox(width: AppSpacing.sm(context)),
          Text(weather, maxLines: 1, style: AppTextStyles.caption(context)),
        ],
        SizedBox(width: AppSpacing.sm(context)),
        AppIconButton(icon: AppIconName.more, onTap: onMore),
      ],
    );
  }
}
