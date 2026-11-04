import 'package:flutter/material.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/moment.dart';

class MomentDetailSheet extends StatefulWidget {
  const MomentDetailSheet({
    super.key,
    required this.moment,
    required this.liked,
    this.onClose,
    this.onLike,
    this.comments,
    this.onAddComment,
  });

  final Moment moment;
  final bool liked;
  final VoidCallback? onClose;
  final VoidCallback? onLike;
  final List<MomentComment>? comments;
  final ValueChanged<String>? onAddComment;

  @override
  State<MomentDetailSheet> createState() => _MomentDetailSheetState();
}

class _MomentDetailSheetState extends State<MomentDetailSheet> {
  final _controller = TextEditingController();
  late bool _liked = widget.liked;
  late final List<MomentComment> _comments = [
    ...(widget.comments ?? widget.moment.comments),
  ];
  bool _closing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (notification) {
        if (!_closing &&
            notification.extent <= notification.minExtent + 0.006) {
          _closing = true;
          widget.onClose?.call();
        }
        return false;
      },
      child: DraggableScrollableSheet(
        expand: false,
      initialChildSize: 0.78,
      maxChildSize: 0.94,
      minChildSize: 0.45,
      builder: (context, controller) {
        return DecoratedBox(
          decoration: const BoxDecoration(
            color: AppColors.surfaceRaised,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: EdgeInsets.all(AppSpacing.lg(context)),
                  children: [
                    Center(child: _Grabber()),
                    SizedBox(height: AppSpacing.sm(context)),
                    Row(
                      children: [
                        Text('动态', style: AppTextStyles.micro(context)),
                        const Spacer(),
                        if (widget.onClose != null)
                          GestureDetector(
                            onTap: widget.onClose,
                            child: Container(
                              width: context.r(28),
                              height: context.r(28),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0x14FFFFFF),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.close_rounded,
                                  size: context.r(16),
                                  color: AppColors.inkMuted,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.md(context)),
                    Text(
                      widget.moment.author,
                      style: AppTextStyles.title(context),
                    ),
                    Text(
                      '${widget.moment.time} · ${widget.moment.place}',
                      style: AppTextStyles.caption(context),
                    ),
                    SizedBox(height: AppSpacing.md(context)),
                    Text(
                      widget.moment.text,
                      style: AppTextStyles.body(context),
                    ),
                    SizedBox(height: AppSpacing.md(context)),
                    for (final photo in widget.moment.photos)
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: AppSpacing.sm(context),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppRadius.md(context),
                          ),
                          child: Image.asset(photo, fit: BoxFit.cover),
                        ),
                      ),
                    SizedBox(height: AppSpacing.sm(context)),
                    GestureDetector(
                      onTap: () {
                        setState(() => _liked = !_liked);
                        widget.onLike?.call();
                      },
                      child: Row(
                        children: [
                          Icon(
                            _liked
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: context.r(17),
                            color: _liked ? AppColors.tint : AppColors.inkMuted,
                          ),
                          SizedBox(width: AppSpacing.xs(context)),
                          Text(
                            '${widget.moment.likes.length + (_liked ? 1 : 0)} 人觉得好',
                            style: AppTextStyles.caption(context),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppSpacing.md(context)),
                    for (final comment in _comments)
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: AppSpacing.sm(context),
                        ),
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '${comment.author}：',
                                style: AppTextStyles.bodyStrong(context),
                              ),
                              TextSpan(
                                text: comment.text,
                                style: AppTextStyles.body(context),
                              ),
                            ],
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              _CommentComposer(controller: _controller, onSend: _send),
            ],
          ),
        );
      },
      ),
    );
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _comments.add(MomentComment(author: '你', text: text, time: '刚刚'));
      _controller.clear();
      widget.onAddComment?.call(text);
    });
  }
}

class _CommentComposer extends StatelessWidget {
  const _CommentComposer({required this.controller, required this.onSend});

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg(context),
          AppSpacing.xs(context),
          AppSpacing.lg(context),
          AppSpacing.sm(context),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                onSubmitted: (_) => onSend(),
                style: AppTextStyles.body(context),
                decoration: InputDecoration(
                  hintText: '写下留言...',
                  hintStyle: AppTextStyles.caption(context),
                  filled: true,
                  fillColor: AppColors.border,
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppRadius.pill(context),
                    ),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            SizedBox(width: AppSpacing.sm(context)),
            GestureDetector(
              onTap: onSend,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: AppColors.tint,
                  shape: BoxShape.circle,
                ),
                child: SizedBox(
                  width: context.r(38),
                  height: context.r(38),
                  child: Icon(
                    Icons.arrow_upward_rounded,
                    size: context.r(18),
                    color: AppColors.ground,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Grabber extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.borderStrong,
        borderRadius: BorderRadius.circular(AppRadius.pill(context)),
      ),
      child: SizedBox(width: context.r(34), height: context.r(4)),
    );
  }
}
