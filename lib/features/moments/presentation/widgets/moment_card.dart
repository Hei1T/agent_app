import 'package:flutter/material.dart';

import '../../../../core/contract/moment.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'moment_photo.dart';

/// 一条动态：单页平面化，没有卡片外壳，只在底部留一条 hairline。
///
/// 对齐 React 稿 `.moment-card`（SINGLE-PAGE PASS）：透明底、0 圆角、
/// padding 12/0、底部分隔线；评论预览也只有一条顶部分隔线，没有底色。
class MomentCard extends StatelessWidget {
  const MomentCard({
    super.key,
    required this.moment,
    required this.liked,
    required this.likeCount,
    required this.onLike,
    required this.onTap,
    this.comments,
    this.divider = true,
  });

  final Moment moment;
  final bool liked;
  final int likeCount;
  final VoidCallback onLike;
  final VoidCallback onTap;
  final List<MomentComment>? comments;

  /// 最后一条动态不画底部 hairline。
  final bool divider;

  @override
  Widget build(BuildContext context) {
    final preview = comments ?? moment.comments;
    final photos = moment.photos
        .where((photo) => photo.url.isNotEmpty)
        .take(3)
        .toList();
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: divider
              ? const Border(
                  bottom: BorderSide(color: AppColors.border, width: 0.5),
                )
              : null,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: context.r(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(moment: moment),
              Padding(
                padding: EdgeInsets.only(top: context.r(9)),
                child: Text(
                  moment.text,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body(context).copyWith(
                    fontSize: context.sp(13.5),
                    height: 1.6,
                    color: AppColors.ink.withValues(alpha: 0.86),
                  ),
                ),
              ),
              if (photos.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: context.r(9)),
                  child: _PhotoGrid(photos: photos),
                ),
              Padding(
                padding: EdgeInsets.only(top: context.r(9)),
                child: _Actions(
                  liked: liked,
                  likes: likeCount,
                  comments: preview.length,
                  onLike: onLike,
                  onComment: onTap,
                ),
              ),
              if (preview.isNotEmpty) _CommentPreview(comments: preview),
            ],
          ),
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
    final author = moment.author.name.isEmpty ? '他' : moment.author.name;
    final time = moment.displayTimeLabel;
    final place = moment.place ?? '';
    final meta = place.isEmpty ? time : '$time · $place';
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(context.r(11)),
          child: SizedBox(
            width: context.r(34),
            height: context.r(34),
            child: Image.asset(
              'assets/media/book1.jpg',
              fit: BoxFit.cover,
              cacheWidth: 110,
            ),
          ),
        ),
        SizedBox(width: context.r(9)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                author,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyStrong(context).copyWith(
                  fontSize: context.sp(13),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: context.r(1)),
                child: Text(
                  meta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption(context).copyWith(
                    fontSize: context.sp(10.5),
                    color: AppColors.inkFaint,
                  ),
                ),
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

  final List<MomentPhoto> photos;

  @override
  Widget build(BuildContext context) {
    if (photos.length == 1) {
      return AspectRatio(
        aspectRatio: 1.9,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(context.r(9)),
          child: MomentPhotoView(source: photos.first.url, cacheWidth: 720),
        ),
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < photos.length; i++) ...[
          if (i > 0) SizedBox(width: context.r(5)),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1.15,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(context.r(9)),
                child: MomentPhotoView(source: photos[i].url, cacheWidth: 480),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.liked,
    required this.likes,
    required this.comments,
    required this.onLike,
    required this.onComment,
  });

  final bool liked;
  final int likes;
  final int comments;
  final VoidCallback onLike;
  final VoidCallback onComment;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ActionButton(
          icon: liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          label: '$likes',
          color: liked ? AppColors.danger : AppColors.inkFaint,
          onTap: onLike,
        ),
        SizedBox(width: context.r(16)),
        _ActionButton(
          icon: Icons.chat_bubble_outline_rounded,
          label: '$comments',
          color: AppColors.inkFaint,
          onTap: onComment,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: context.r(2)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: context.r(16), color: color),
            SizedBox(width: context.r(4)),
            Text(
              label,
              maxLines: 1,
              style: AppTextStyles.caption(
                context,
              ).copyWith(fontSize: context.sp(10.5), color: color, height: 1.3),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentPreview extends StatelessWidget {
  const _CommentPreview({required this.comments});

  final List<MomentComment> comments;

  @override
  Widget build(BuildContext context) {
    final first = comments.first;
    final author = first.author.name.isEmpty ? '他' : first.author.name;
    final base = AppTextStyles.body(context).copyWith(
      fontSize: context.sp(11),
      height: 1.5,
      color: AppColors.inkSecondary,
    );
    return Padding(
      padding: EdgeInsets.only(top: context.r(8)),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
        ),
        child: Padding(
          padding: EdgeInsets.only(top: context.r(8)),
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$author：',
                  style: base.copyWith(
                    color: AppColors.ink.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextSpan(text: first.text),
                if (comments.length > 1)
                  TextSpan(
                    text: '\n等 ${comments.length} 条留言',
                    style: base.copyWith(
                      fontSize: context.sp(10),
                      color: AppColors.inkFaint,
                    ),
                  ),
              ],
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: base,
          ),
        ),
      ),
    );
  }
}
