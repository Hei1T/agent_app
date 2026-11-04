import 'package:flutter/material.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/chat_message.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final fromCompanion = message.fromCompanion;
    return Row(
      mainAxisAlignment: fromCompanion
          ? MainAxisAlignment.start
          : MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (fromCompanion) ...[
          ClipOval(
            child: SizedBox(
              width: context.r(24),
              height: context.r(24),
              child: Image.asset('assets/media/book1.jpg', fit: BoxFit.cover),
            ),
          ),
          SizedBox(width: AppSpacing.xs(context)),
        ],
        Flexible(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.76,
            ),
            child: DecoratedBox(
            decoration: BoxDecoration(
              color: fromCompanion ? AppColors.surfaceRaised : AppColors.tint,
              borderRadius: BorderRadius.circular(AppRadius.md(context)),
              border: fromCompanion
                  ? Border.all(color: AppColors.border)
                  : null,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.r(11),
                vertical: context.r(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: fromCompanion
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.end,
                children: [
                  Text(
                    message.text,
                    maxLines: 6,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body(context).copyWith(
                      fontSize: context.sp(11.5),
                      height: 1.5,
                      color: fromCompanion ? AppColors.ink : AppColors.ground,
                    ),
                  ),
                  if (!fromCompanion && message.read) ...[
                    SizedBox(height: context.r(3)),
                    Text(
                      '已读',
                      style: AppTextStyles.micro(context).copyWith(
                        fontSize: context.sp(8.5),
                        color: AppColors.ground.withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            ),
          ),
        ),
      ],
    );
  }
}
