import 'package:flutter/material.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/today_entities.dart';

/// 今天时间线：单页平面化，没有外层卡片，行与行之间只有 0.5px hairline。
///
/// 对齐 React 稿 `.today-single .timeline-card / .timeline-row`：
/// 行内 padding 10/2、头像 40、行尾时间靠右、正文 12.5。
class TimelineCard extends StatelessWidget {
  const TimelineCard({super.key, required this.entries});

  final List<TimelineEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        for (var i = 0; i < entries.length; i++)
          _TimelineRow(
            key: ValueKey('timeline_${entries[i].id}'),
            entry: entries[i],
            last: i == entries.length - 1,
          ),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({super.key, required this.entry, required this.last});

  final TimelineEntry entry;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final photo = entry.photo;
    final hasPhoto = photo != null && photo.isNotEmpty;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(
                bottom: BorderSide(color: AppColors.border, width: 0.5),
              ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.r(2),
              vertical: context.r(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasPhoto) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(context.r(6)),
                    child: SizedBox(
                      width: context.r(40),
                      height: context.r(40),
                      child: Image.asset(
                        photo,
                        fit: BoxFit.cover,
                        cacheWidth: 160,
                      ),
                    ),
                  ),
                  SizedBox(width: context.r(10)),
                ],
                Expanded(child: _TimelineBody(entry: entry)),
              ],
            ),
          ),
          if (entry.unread > 0)
            Positioned(
              right: context.r(8),
              top: context.r(34),
              child: _UnreadBadge(count: entry.unread),
            ),
        ],
      ),
    );
  }
}

class _TimelineBody extends StatelessWidget {
  const _TimelineBody({required this.entry});

  final TimelineEntry entry;

  @override
  Widget build(BuildContext context) {
    return Column(
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
                style: AppTextStyles.bodyStrong(context).copyWith(
                  fontSize: context.sp(13.5),
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ),
            SizedBox(width: AppSpacing.sm(context)),
            Text(
              entry.time,
              maxLines: 1,
              style: AppTextStyles.caption(context).copyWith(
                fontSize: context.sp(10.5),
                color: AppColors.inkFaint,
                height: 1.35,
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(top: context.r(2)),
          child: Text(
            entry.detail,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body(context).copyWith(
              fontSize: context.sp(12.5),
              height: 1.55,
              color: AppColors.inkSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.danger,
        borderRadius: BorderRadius.circular(context.r(9)),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: context.r(17),
          minHeight: context.r(17),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.r(5),
            vertical: context.r(2.5),
          ),
          child: Center(
            widthFactor: 1,
            child: Text(
              '$count',
              maxLines: 1,
              style: AppTextStyles.caption(context).copyWith(
                fontSize: context.sp(10),
                height: 1,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
