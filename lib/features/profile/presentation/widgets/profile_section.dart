import 'package:flutter/material.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 主页分区：透明底，仅顶部 hairline，不是卡片。
class ProfileSection extends StatelessWidget {
  const ProfileSection({
    super.key,
    required this.title,
    required this.child,
    this.meta,
  });

  final String title;
  final String? meta;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyStrong(
                      context,
                    ).copyWith(fontSize: context.sp(14), color: AppColors.ink),
                  ),
                ),
                if (meta != null) ...[
                  SizedBox(width: AppSpacing.sm(context)),
                  Text(
                    meta!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption(context).copyWith(
                      fontSize: context.sp(10.5),
                      color: AppColors.inkFaint,
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: AppSpacing.sm(context)),
            child,
          ],
        ),
      ),
    );
  }
}
