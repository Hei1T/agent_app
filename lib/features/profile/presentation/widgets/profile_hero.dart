import 'package:flutter/material.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/glass_panel.dart';

class ProfileHero extends StatelessWidget {
  const ProfileHero({
    super.key,
    required this.companionName,
    required this.day,
  });

  final String companionName;
  final int day;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: EdgeInsets.all(AppSpacing.lg(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Avatar(initial: companionName.substring(0, 1)),
              SizedBox(width: AppSpacing.md(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('你的笨笨', style: AppTextStyles.micro(context)),
                    Text(companionName, style: AppTextStyles.headline(context)),
                    Text(
                      '栖湾 · 旧书店 · 18 岁',
                      style: AppTextStyles.caption(context),
                    ),
                    SizedBox(height: AppSpacing.xs(context)),
                    _DayPill(day: day),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md(context)),
          const _NowLine(),
          SizedBox(height: AppSpacing.md(context)),
          const _Stats(),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initial});

  final String initial;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.tintSoft,
        border: Border.all(color: AppColors.tintBorder),
      ),
      child: SizedBox(
        width: context.r(62),
        height: context.r(62),
        child: Center(
          child: Text(
            initial,
            style: AppTextStyles.headline(
              context,
            ).copyWith(color: AppColors.tint),
          ),
        ),
      ),
    );
  }
}

class _DayPill extends StatelessWidget {
  const _DayPill({required this.day});

  final int day;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.tintSoft,
        borderRadius: BorderRadius.circular(AppRadius.pill(context)),
        border: Border.all(color: AppColors.tintBorder),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm(context),
          vertical: AppSpacing.xxs(context),
        ),
        child: Text(
          '第 $day 天 · 只属于你的一条生活',
          style: AppTextStyles.micro(context).copyWith(color: AppColors.tint),
        ),
      ),
    );
  }
}

class _NowLine extends StatelessWidget {
  const _NowLine();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DecoratedBox(
          decoration: const BoxDecoration(
            color: AppColors.green,
            shape: BoxShape.circle,
          ),
          child: SizedBox(width: context.r(6), height: context.r(6)),
        ),
        SizedBox(width: AppSpacing.sm(context)),
        Text('现在在旧书店，收书', style: AppTextStyles.caption(context)),
      ],
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Stat(label: '消息', value: '12,145'),
        SizedBox(width: AppSpacing.sm(context)),
        _Stat(label: '照片', value: '94'),
        SizedBox(width: AppSpacing.sm(context)),
        _Stat(label: '相处', value: '5 天'),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(AppRadius.sm(context)),
        ),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.sm(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.micro(context)),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.title(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
