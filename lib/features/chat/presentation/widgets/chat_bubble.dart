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
              width: context.r(26),
              height: context.r(26),
              child: Image.asset('assets/media/book1.jpg', fit: BoxFit.cover),
            ),
          ),
          SizedBox(width: AppSpacing.xs(context)),
        ],
        Flexible(
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
                horizontal: AppSpacing.sm(context),
                vertical: AppSpacing.xs(context),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      message.text,
                      maxLines: 6,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body(context).copyWith(
                        color: fromCompanion ? AppColors.ink : AppColors.ground,
                      ),
                    ),
                  ),
                  if (!fromCompanion && message.read) ...[
                    SizedBox(width: context.r(5)),
                    Text(
                      '已读',
                      style: AppTextStyles.micro(context).copyWith(
                        fontSize: context.sp(6.5),
                        color: AppColors.ground.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
