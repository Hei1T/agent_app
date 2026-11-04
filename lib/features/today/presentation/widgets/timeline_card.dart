import 'package:flutter/material.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/today_entities.dart';

class TimelineCard extends StatelessWidget {
  const TimelineCard({super.key, required this.entries});

  final List<TimelineEntry> entries;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg(context)),
        color: const Color(0x10FFFFFF),
        border: Border.all(color: const Color(0x24FFFFFF)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < entries.length; i++) ...[
            _TimelineRow(entry: entries[i]),
            if (i != entries.length - 1)
              Padding(
                padding: EdgeInsets.only(left: context.r(62)),
                child: const Divider(height: 0.5, color: AppColors.divider),
              ),
          ],
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.entry});

  final TimelineEntry entry;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.isPortrait ? context.r(12) : AppSpacing.md(context),
            vertical: context.r(9),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (entry.photo != null && entry.photo!.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(context.r(13)),
                  child: SizedBox(
                    width: context.r(40),
                    height: context.r(40),
                    child: Image.asset(
                      entry.photo!,
                      fit: BoxFit.cover,
                      cacheWidth: 120,
                    ),
                  ),
                ),
                SizedBox(width: context.r(10)),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Expanded(
                          child: Text(
                            entry.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyStrong(
                              context,
                            ).copyWith(fontSize: context.sp(12.5)),
                          ),
                        ),
                        Text(
                          entry.time,
                          style: AppTextStyles.caption(
                            context,
                          ).copyWith(fontSize: context.sp(9.5)),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.xxs(context)),
                    Text(
                      entry.detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body(
                        context,
                      ).copyWith(fontSize: context.sp(10.5)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (entry.unread > 0)
          Positioned(
            right: context.r(10),
            top: context.r(30),
            child: Container(
              constraints: BoxConstraints(minWidth: context.r(17)),
              height: context.r(17),
              padding: EdgeInsets.symmetric(horizontal: context.r(5)),
              decoration: BoxDecoration(
                color: AppColors.danger,
                borderRadius: BorderRadius.circular(context.r(9)),
              ),
              child: Center(
                child: Text(
                  '${entry.unread}',
                  style: AppTextStyles.micro(context).copyWith(
                    color: Colors.white,
                    fontSize: context.sp(9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
