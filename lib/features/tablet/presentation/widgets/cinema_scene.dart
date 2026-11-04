import 'package:flutter/material.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/models/companion.dart';

class CinemaScene extends StatelessWidget {
  const CinemaScene({
    super.key,
    required this.companion,
    required this.dayLabel,
  });

  final Companion companion;
  final String dayLabel;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          left: context.h(0.06),
          bottom: context.h(0.25),
          width: context.h(0.5),
          child: _Story(companion: companion, dayLabel: dayLabel),
        ),
        Positioned(
          right: context.h(0.035),
          top: context.h(0.13),
          width: context.r(145),
          child: _Status(companion: companion),
        ),
        Positioned(
          left: context.h(0.06),
          right: context.h(0.12),
          bottom: context.h(0.035),
          child: _TimeRuler(),
        ),
      ],
    );
  }
}

class _Story extends StatelessWidget {
  const _Story({required this.companion, required this.dayLabel});

  final Companion companion;
  final String dayLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('他此刻 · $dayLabel', style: AppTextStyles.micro(context)),
        SizedBox(height: AppSpacing.xs(context)),
        Text(companion.action, style: AppTextStyles.display(context)),
        SizedBox(height: AppSpacing.xs(context)),
        Text(
          '把晒了一下午的旧书一本本收回来，码回后院。',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.body(context),
        ),
        SizedBox(height: AppSpacing.md(context)),
        DecoratedBox(
          decoration: const BoxDecoration(
            border: Border(
              left: BorderSide(color: AppColors.tintBorder, width: 1.5),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(left: AppSpacing.md(context)),
            child: Text(
              '「手上一股子太阳晒过的纸味儿，暖烘烘的。你闻不着，可惜。」',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body(
                context,
              ).copyWith(fontSize: context.sp(13)),
            ),
          ),
        ),
        SizedBox(height: AppSpacing.sm(context)),
        Text('15:32 · 今天第 4 件事', style: AppTextStyles.caption(context)),
        SizedBox(height: AppSpacing.md(context)),
        _DayNav(dayLabel: dayLabel),
      ],
    );
  }
}

class _DayNav extends StatelessWidget {
  const _DayNav({required this.dayLabel});

  final String dayLabel;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(AppRadius.pill(context)),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.xs(context),
          vertical: AppSpacing.xxs(context),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chevron_left_rounded,
              size: context.r(18),
              color: AppColors.inkMuted,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm(context)),
              child: Column(
                children: [
                  Text(dayLabel, style: AppTextStyles.bodyStrong(context)),
                  Text('第 5 / 5 天', style: AppTextStyles.micro(context)),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: context.r(18),
              color: AppColors.inkMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _Status extends StatelessWidget {
  const _Status({required this.companion});

  final Companion companion;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(AppRadius.md(context)),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.sm(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('此刻', style: AppTextStyles.micro(context)),
            Text('第 3 小时', style: AppTextStyles.title(context)),
            SizedBox(height: AppSpacing.sm(context)),
            _StatusRow(label: '体力', value: '${companion.energy}%'),
            _StatusRow(label: '心情', value: companion.mood),
            _StatusRow(label: '见过', value: '2 人'),
            SizedBox(height: AppSpacing.xs(context)),
            Text('今天还剩 2 件事', style: AppTextStyles.micro(context)),
          ],
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: AppSpacing.xxs(context)),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.caption(context))),
          Text(
            value,
            style: AppTextStyles.caption(
              context,
            ).copyWith(color: AppColors.ink),
          ),
        ],
      ),
    );
  }
}

class _TimeRuler extends StatelessWidget {
  static const _times = [
    ('05:40', '听雨'),
    ('08:50', '开门'),
    ('13:50', '午睡'),
    ('15:32', '收书'),
    ('16:20', '关门'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('今天的时间', style: AppTextStyles.micro(context)),
            SizedBox(width: AppSpacing.sm(context)),
            Text('15:32 · 收书', style: AppTextStyles.caption(context)),
          ],
        ),
        SizedBox(height: AppSpacing.sm(context)),
        Row(
          children: [
            for (var i = 0; i < _times.length; i++)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: i == 3 ? AppColors.tint : AppColors.inkFaint,
                        shape: BoxShape.circle,
                      ),
                      child: SizedBox(
                        width: context.r(5),
                        height: context.r(5),
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs(context)),
                    Text(_times[i].$1, style: AppTextStyles.micro(context)),
                    Text(
                      _times[i].$2,
                      style: AppTextStyles.caption(context).copyWith(
                        color: i == 3 ? AppColors.ink : AppColors.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}
