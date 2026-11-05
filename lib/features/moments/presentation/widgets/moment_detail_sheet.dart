import 'package:flutter/material.dart';

import '../../../../core/contract/contract_format.dart';
import '../../../../core/contract/moment.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/full_screen_photo_preview.dart';
import 'moment_photo.dart';

class MomentDetailSheet extends StatefulWidget {
  const MomentDetailSheet({
    super.key,
    required this.moment,
    required this.liked,
    this.onLike,
    this.comments,
    this.onAddComment,
  });

  final Moment moment;
  final bool liked;

  /// 返回 true 表示后端已确认；false 时本弹层回滚本地状态。
  final Future<bool> Function()? onLike;
  final List<MomentComment>? comments;

  /// 返回后端留言；null 表示失败，本弹层回滚临时留言。
  final Future<MomentComment?> Function(String text)? onAddComment;

  @override
  State<MomentDetailSheet> createState() => _MomentDetailSheetState();
}

class _MomentDetailSheetState extends State<MomentDetailSheet> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  late bool _liked = widget.liked;
  late final List<MomentComment> _comments = [
    ...(widget.comments ?? widget.moment.comments),
  ];
  bool _liking = false;

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photos = widget.moment.photos
        .where((photo) => photo.url.isNotEmpty)
        .toList();
    return Column(
      children: [
        Expanded(
          child: ListView(
            controller: _scroll,
            padding: EdgeInsets.fromLTRB(
              context.r(2),
              context.r(11),
              context.r(2),
              context.r(12),
            ),
            children: [
              _AuthorHeader(moment: widget.moment),
              Padding(
                padding: EdgeInsets.only(top: context.r(11)),
                child: Text(
                  widget.moment.text,
                  style: AppTextStyles.body(context).copyWith(
                    fontSize: context.sp(13),
                    height: 1.75,
                    color: AppColors.ink.withValues(alpha: 0.88),
                  ),
                ),
              ),
              _PhotoRow(photos: photos, onOpen: _openPhoto),
              _DetailActions(
                liked: _liked,
                likeCount: widget.moment.likes.length + (_liked ? 1 : 0),
                commentCount: _comments.length,
                onLike: _toggleLike,
              ),
              _LikesSection(
                names: [
                  for (final like in widget.moment.likes)
                    if (like.name != null && like.name!.isNotEmpty) like.name!,
                  if (_liked && !_serverPlayerLiked) '你',
                ],
              ),
              _CommentsSection(comments: _comments),
            ],
          ),
        ),
        _CommentComposer(controller: _input, onSend: _send),
      ],
    );
  }

  bool get _serverPlayerLiked =>
      widget.moment.likes.any((like) => like.actorType == 'player');

  Future<void> _toggleLike() async {
    if (_liking) return;
    setState(() {
      _liked = !_liked;
      _liking = true;
    });
    final onLike = widget.onLike;
    final ok = onLike == null ? true : await onLike();
    if (!mounted) return;
    setState(() => _liking = false);
    if (!ok) {
      setState(() => _liked = !_liked);
      _toast('点赞没同步上，已回滚。');
    }
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    final temp = MomentComment(
      id: 'local-${DateTime.now().microsecondsSinceEpoch}',
      author: const MomentAuthor(type: 'player', name: '你'),
      text: text,
      timeLabel: '刚刚',
    );
    setState(() {
      _comments.add(temp);
      _input.clear();
    });
    _scrollToEnd();
    final onAddComment = widget.onAddComment;
    final saved = onAddComment == null ? null : await onAddComment(text);
    if (!mounted) return;
    if (saved == null) {
      setState(() {
        _comments.removeWhere((comment) => comment.id == temp.id);
      });
      _toast('留言没发出去，已回滚。');
      return;
    }
    setState(() {
      final index = _comments.indexWhere((comment) => comment.id == temp.id);
      if (index >= 0) _comments[index] = saved;
    });
    _scrollToEnd();
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _openPhoto(String source) {
    showFullScreenPhotoPreview(context, source);
  }
}

class _AuthorHeader extends StatelessWidget {
  const _AuthorHeader({required this.moment});

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
          borderRadius: BorderRadius.circular(context.r(9)),
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
                style: AppTextStyles.bodyStrong(
                  context,
                ).copyWith(fontSize: context.sp(13)),
              ),
              Text(
                meta,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption(context).copyWith(
                  fontSize: context.sp(10.5),
                  color: AppColors.inkFaint,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PhotoRow extends StatelessWidget {
  const _PhotoRow({required this.photos, required this.onOpen});

  final List<MomentPhoto> photos;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) return SizedBox(height: context.r(11));
    if (photos.length == 1) {
      return Padding(
        padding: EdgeInsets.only(top: context.r(11)),
        child: GestureDetector(
          onTap: () => onOpen(photos.first.url),
          child: AspectRatio(
            aspectRatio: 1.9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(context.r(9)),
              child: MomentPhotoView(
                source: photos.first.url,
                cacheWidth: 1080,
              ),
            ),
          ),
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.only(top: context.r(11)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < photos.length; i++) ...[
            if (i > 0) SizedBox(width: context.r(5)),
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: GestureDetector(
                  onTap: () => onOpen(photos[i].url),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(context.r(9)),
                    child: MomentPhotoView(
                      source: photos[i].url,
                      cacheWidth: 720,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailActions extends StatelessWidget {
  const _DetailActions({
    required this.liked,
    required this.likeCount,
    required this.commentCount,
    required this.onLike,
  });

  final bool liked;
  final int likeCount;
  final int commentCount;
  final VoidCallback onLike;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: context.r(11)),
      padding: EdgeInsets.only(bottom: context.r(10)),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0x12FFFFFF), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onLike,
            child: Row(
              children: [
                Icon(
                  liked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  size: context.r(17),
                  color: liked ? const Color(0xFFFF6B5E) : AppColors.inkFaint,
                ),
                SizedBox(width: context.r(4)),
                Text(
                  likeCount.toString(),
                  style: AppTextStyles.caption(
                    context,
                  ).copyWith(fontSize: context.sp(10)),
                ),
                SizedBox(width: context.r(5)),
                Text(
                  liked ? '已赞' : '点赞',
                  style: AppTextStyles.caption(context).copyWith(
                    fontSize: context.sp(9),
                    color: AppColors.inkFaint,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Text(
            '$commentCount 条留言',
            style: AppTextStyles.caption(
              context,
            ).copyWith(fontSize: context.sp(9), color: AppColors.inkFaint),
          ),
        ],
      ),
    );
  }
}

class _LikesSection extends StatelessWidget {
  const _LikesSection({required this.names});

  final List<String> names;

  @override
  Widget build(BuildContext context) {
    if (names.isEmpty) return SizedBox(height: context.r(10));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: context.r(12), bottom: context.r(7)),
          child: Text(
            '赞',
            style: AppTextStyles.caption(context).copyWith(
              fontSize: context.sp(9),
              letterSpacing: 0.8,
              color: AppColors.inkFaint,
            ),
          ),
        ),
        Wrap(
          spacing: context.r(5),
          runSpacing: context.r(5),
          children: [
            for (final name in names)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.r(8),
                  vertical: context.r(4),
                ),
                decoration: BoxDecoration(
                  color: const Color(0x0FFFFFFF),
                  borderRadius: BorderRadius.circular(context.r(999)),
                  border: Border.all(
                    color: const Color(0x14FFFFFF),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  name,
                  style: AppTextStyles.caption(
                    context,
                  ).copyWith(fontSize: context.sp(9)),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _CommentsSection extends StatelessWidget {
  const _CommentsSection({required this.comments});

  final List<MomentComment> comments;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: context.r(12), bottom: context.r(5)),
          child: Text(
            '留言 ${comments.length}',
            style: AppTextStyles.caption(context).copyWith(
              fontSize: context.sp(9),
              letterSpacing: 0.8,
              color: AppColors.inkFaint,
            ),
          ),
        ),
        if (comments.isEmpty)
          Text(
            '还没有留言。',
            style: AppTextStyles.caption(
              context,
            ).copyWith(fontSize: context.sp(9.5), color: AppColors.inkFaint),
          )
        else
          for (final comment in comments) _CommentRow(comment: comment),
      ],
    );
  }
}

class _CommentRow extends StatelessWidget {
  const _CommentRow({required this.comment});

  final MomentComment comment;

  @override
  Widget build(BuildContext context) {
    final author = comment.author.name.isEmpty ? '他' : comment.author.name;
    final time =
        comment.timeLabel ?? contractClockLabel(comment.createdAt) ?? '';
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.r(7)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: context.r(26),
            height: context.r(26),
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0x14FFFFFF),
              shape: BoxShape.circle,
            ),
            child: Text(
              author.substring(0, 1),
              style: AppTextStyles.caption(
                context,
              ).copyWith(fontSize: context.sp(9)),
            ),
          ),
          SizedBox(width: context.r(8)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  author,
                  style: AppTextStyles.bodyStrong(context).copyWith(
                    fontSize: context.sp(10),
                    color: AppColors.ink.withValues(alpha: 0.72),
                  ),
                ),
                Text(
                  comment.text,
                  style: AppTextStyles.body(
                    context,
                  ).copyWith(fontSize: context.sp(11), height: 1.6),
                ),
                if (time.isNotEmpty)
                  Text(
                    time,
                    style: AppTextStyles.caption(context).copyWith(
                      fontSize: context.sp(8.5),
                      color: AppColors.inkFaint,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentComposer extends StatelessWidget {
  const _CommentComposer({required this.controller, required this.onSend});

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.r(16),
        context.r(4),
        context.r(16),
        context.r(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: context.r(38),
              padding: EdgeInsets.only(
                left: context.r(12),
                right: context.r(8),
              ),
              decoration: BoxDecoration(
                color: const Color(0x0EFFFFFF),
                borderRadius: BorderRadius.circular(context.r(18)),
                border: Border.all(color: const Color(0x1AFFFFFF), width: 0.5),
              ),
              child: TextField(
                controller: controller,
                onSubmitted: (_) => onSend(),
                style: AppTextStyles.body(
                  context,
                ).copyWith(fontSize: context.sp(11)),
                decoration: InputDecoration(
                  hintText: '写下留言...',
                  hintStyle: AppTextStyles.caption(context).copyWith(
                    fontSize: context.sp(10),
                    color: AppColors.inkFaint,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
          ),
          SizedBox(width: context.r(8)),
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: context.r(34),
              height: context.r(34),
              decoration: const BoxDecoration(
                color: AppColors.tint,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_upward_rounded,
                size: context.r(17),
                color: AppColors.ground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
