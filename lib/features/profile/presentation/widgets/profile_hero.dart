import 'package:flutter/material.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 他：主页头部。单页平面化：透明底、无边框圆角，仅底部 hairline。
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
    return Container(
      key: const Key('profile_hero'),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.md(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _Avatar(initial: companionName.substring(0, 1)),
                SizedBox(width: AppSpacing.md(context)),
                Expanded(
                  child: _Identity(companionName: companionName, day: day),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md(context)),
            const _NowLine(),
            SizedBox(height: AppSpacing.md(context)),
            const _Stats(),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initial});

  final String initial;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: context.r(62),
          height: context.r(62),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.tintSoft,
            border: Border.all(color: AppColors.tintBorder),
          ),
          child: Text(
            initial,
            style: AppTextStyles.headline(
              context,
            ).copyWith(fontSize: context.sp(25), color: AppColors.tint),
          ),
        ),
        Positioned(
          right: context.r(2),
          bottom: context.r(5),
          child: Container(
            width: context.r(9),
            height: context.r(9),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.tint,
              border: Border.all(color: AppColors.surface, width: context.r(2)),
            ),
          ),
        ),
      ],
    );
  }
}

class _Identity extends StatelessWidget {
  const _Identity({required this.companionName, required this.day});

  final String companionName;
  final int day;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '你的笨笨',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.micro(context).copyWith(
            fontSize: context.sp(10.5),
            letterSpacing: 1.6,
            color: AppColors.inkFaint,
          ),
        ),
        Text(
          companionName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.headline(
            context,
          ).copyWith(fontSize: context.sp(22), letterSpacing: -0.3),
        ),
        Text(
          '栖湾 · 旧书店 · 18 岁',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.caption(
            context,
          ).copyWith(fontSize: context.sp(11), color: AppColors.inkMuted),
        ),
        SizedBox(height: AppSpacing.xxs(context)),
        Text(
          '第 $day 天 · 只属于你的一条生活',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.caption(
            context,
          ).copyWith(fontSize: context.sp(10.5), color: AppColors.tint),
        ),
      ],
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
          child: SizedBox(width: context.r(5), height: context.r(5)),
        ),
        SizedBox(width: context.r(6)),
        Flexible(
          child: Text(
            '现在在旧书店，收书',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption(
              context,
            ).copyWith(fontSize: context.sp(10.5), color: AppColors.inkMuted),
          ),
        ),
      ],
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats();

  static const _labels = ['消息', '照片', '相处'];
  static const _values = ['12,145', '94', '5 天'];

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          for (var i = 0; i < _labels.length; i++)
            Expanded(
              child: _Stat(
                label: _labels[i],
                value: _values[i],
                showDivider: i > 0,
              ),
            ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    required this.showDivider,
  });

  final String label;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: showDivider ? context.r(10) : 0,
        right: context.r(10),
      ),
      decoration: showDivider
          ? const BoxDecoration(
              border: Border(left: BorderSide(color: AppColors.border)),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption(
              context,
            ).copyWith(fontSize: context.sp(10), color: AppColors.inkFaint),
          ),
          SizedBox(height: context.r(2)),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.title(context).copyWith(
              fontSize: context.sp(19),
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
