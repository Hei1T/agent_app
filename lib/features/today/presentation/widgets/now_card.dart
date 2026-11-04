import 'package:flutter/material.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/models/companion.dart';

class NowCard extends StatelessWidget {
  const NowCard({super.key, required this.companion, required this.onTap});

  final Companion companion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const Key('today_now_card'),
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(context.r(18)),
          border: Border.all(color: AppColors.border),
          gradient: const RadialGradient(
            center: Alignment.topRight,
            radius: 1.2,
            colors: [Color(0x1FFFB183), Color(0x00000000)],
          ),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg(context)),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xC72B211B), Color(0xCC120D0B)],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(context.r(13)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _Avatar(initial: companion.name.substring(0, 1)),
                    SizedBox(width: AppSpacing.sm(context)),
                    Expanded(child: _TitleBlock(companion: companion)),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: context.r(16),
                      color: AppColors.inkFaint,
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.sm(context)),
                _Stats(companion: companion),
                SizedBox(height: context.r(9)),
                Container(
                  padding: EdgeInsets.only(top: context.r(8)),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Color(0x0FFFFFFF), width: 0.5),
                    ),
                  ),
                  child: Text(
                    '“把晒了一下午的旧书一本本收回来，码回后院。”',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body(context).copyWith(
                      fontSize: context.sp(9),
                      height: 1.55,
                      color: AppColors.inkMuted,
                    ),
                  ),
                ),
                SizedBox(height: context.r(5)),
                Text(
                  '这一条生活，只在这里发生',
                  style: AppTextStyles.micro(context).copyWith(
                    fontSize: context.sp(7.5),
                    letterSpacing: 0.06,
                  ),
                ),
              ],
            ),
          ),
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
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.tintSoft,
        border: Border.all(color: AppColors.tintBorder),
      ),
      child: SizedBox(
        width: context.r(42),
        height: context.r(42),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              initial,
              style: AppTextStyles.title(
                context,
              ).copyWith(color: AppColors.tint, fontSize: context.sp(17)),
            ),
            Positioned(
              right: context.r(2),
              bottom: context.r(3),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.green,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF1B1412),
                    width: context.r(2),
                  ),
                ),
                child: SizedBox(width: context.r(6), height: context.r(6)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TitleBlock extends StatelessWidget {
  const _TitleBlock({required this.companion});

  final Companion companion;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('他此刻 · 第 ${companion.day} 天', style: AppTextStyles.micro(context)),
        Text(
          '在${companion.place} · ${companion.action}',
          style: AppTextStyles.title(
            context,
          ).copyWith(fontSize: context.sp(13)),
        ),
        Text(
          '11月2日 周日 · 雨 1.7°C',
          style: AppTextStyles.caption(
            context,
          ).copyWith(fontSize: context.sp(8.5)),
        ),
      ],
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({required this.companion});

  final Companion companion;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Stat(label: '体力', value: '${companion.energy}%'),
        SizedBox(width: AppSpacing.xs(context)),
        _Stat(label: '心情', value: companion.mood),
        SizedBox(width: AppSpacing.xs(context)),
        const _Stat(label: '在店', value: '3 小时'),
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
          borderRadius: BorderRadius.circular(AppRadius.sm(context)),
          color: const Color(0x0BFFFFFF),
          border: Border.all(color: AppColors.divider),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm(context),
            vertical: AppSpacing.xs(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.micro(context),
              ),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyStrong(
                  context,
                ).copyWith(fontSize: context.sp(11)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
