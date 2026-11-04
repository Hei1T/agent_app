import 'package:flutter/material.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/glass_panel.dart';
import '../../domain/entities/moment.dart';

class MomentCard extends StatelessWidget {
  const MomentCard({
    super.key,
    required this.moment,
    required this.liked,
    required this.onLike,
    required this.onTap,
    this.comments,
  });

  final Moment moment;
  final bool liked;
  final VoidCallback onLike;
  final VoidCallback onTap;
  final List<MomentComment>? comments;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassPanel(
        padding: EdgeInsets.all(AppSpacing.md(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(moment: moment),
            SizedBox(height: AppSpacing.sm(context)),
            Text(
              moment.text,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body(
                context,
              ).copyWith(fontSize: context.sp(11.5), height: 1.65),
            ),
            if (moment.photos.isNotEmpty) ...[
              SizedBox(height: context.r(9)),
              _PhotoGrid(photos: moment.photos),
            ],
            SizedBox(height: AppSpacing.sm(context)),
            _Actions(
              liked: liked,
              likes: moment.likes.length + (liked ? 1 : 0),
              comments: (comments ?? moment.comments).length,
              onLike: onLike,
            ),
            if ((comments ?? moment.comments).isNotEmpty) ...[
              SizedBox(height: context.r(8)),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: context.r(9),
                  vertical: context.r(7),
                ),
                decoration: BoxDecoration(
                  color: const Color(0x0BFFFFFF),
                  borderRadius: BorderRadius.circular(context.r(9)),
                ),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${moment.comments.first.author}：',
                        style: const TextStyle(
                          color: Color(0xB3F7F2EB),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextSpan(text: (comments ?? moment.comments).first.text),
                      if ((comments ?? moment.comments).length > 1)
                        TextSpan(
                          text: '\n等 ${(comments ?? moment.comments).length} 条留言',
                          style: TextStyle(
                            fontSize: context.sp(8.5),
                            color: AppColors.inkFaint,
                          ),
                        ),
                    ],
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption(
                    context,
                  ).copyWith(fontSize: context.sp(9.5), height: 1.45),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.moment});

  final Moment moment;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipOval(
          child: SizedBox(
            width: context.r(30),
            height: context.r(30),
            child: Image.asset('assets/media/book1.jpg', fit: BoxFit.cover),
          ),
        ),
        SizedBox(width: context.r(9)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                moment.author,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyStrong(
                  context,
                ).copyWith(fontSize: context.sp(11.5)),
              ),
              Text(
                '${moment.time} · ${moment.place}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption(
                  context,
                ).copyWith(fontSize: context.sp(8.5)),
              ),
            ],
          ),
        ),
        Icon(
          Icons.more_horiz_rounded,
          size: context.r(16),
          color: AppColors.inkFaint,
        ),
      ],
    );
  }
}

class _PhotoGrid extends StatelessWidget {
  const _PhotoGrid({required this.photos});

  final List<String> photos;

  @override
  Widget build(BuildContext context) {
    if (photos.length == 1) {
      return AspectRatio(
        aspectRatio: 1.9,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.md(context)),
          child: Image.asset(photos.first, fit: BoxFit.cover),
        ),
      );
    }
    final count = photos.length >= 3 ? 3 : 2;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: photos.length > count ? count : photos.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: count,
        crossAxisSpacing: context.r(5),
        childAspectRatio: 1.15,
      ),
      itemBuilder: (context, i) => ClipRRect(
        borderRadius: BorderRadius.circular(context.r(9)),
        child: Image.asset(photos[i], fit: BoxFit.cover, cacheWidth: 480),
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.liked,
    required this.likes,
    required this.comments,
    required this.onLike,
  });

  final bool liked;
  final int likes;
  final int comments;
  final VoidCallback onLike;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onLike,
          child: Row(
            children: [
              Icon(
                liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                size: context.r(16),
                color: liked ? AppColors.tint : AppColors.inkMuted,
              ),
              SizedBox(width: AppSpacing.xxs(context)),
              Text('$likes', style: AppTextStyles.caption(context)),
            ],
          ),
        ),
        SizedBox(width: AppSpacing.md(context)),
        Icon(
          Icons.chat_bubble_outline_rounded,
          size: context.r(15),
          color: AppColors.inkMuted,
        ),
        SizedBox(width: AppSpacing.xxs(context)),
        Text('$comments', style: AppTextStyles.caption(context)),
      ],
    );
  }
}
