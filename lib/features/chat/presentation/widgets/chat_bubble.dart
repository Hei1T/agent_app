import 'package:flutter/material.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/chat_message.dart';
import 'chat_message_content.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    this.showAvatar = true,
    this.showRead = false,
  });

  final ChatMessage message;
  final bool showAvatar;
  final bool showRead;

  @override
  Widget build(BuildContext context) {
    final fromCompanion = message.fromCompanion;
    final radius = BorderRadius.only(
      topLeft: Radius.circular(context.r(12)),
      topRight: Radius.circular(context.r(12)),
      bottomLeft: Radius.circular(context.r(fromCompanion ? 3 : 12)),
      bottomRight: Radius.circular(context.r(fromCompanion ? 12 : 3)),
    );
    return Row(
      mainAxisAlignment: fromCompanion
          ? MainAxisAlignment.start
          : MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (fromCompanion) ...[
          if (showAvatar)
            ClipRRect(
              borderRadius: BorderRadius.circular(context.r(6)),
              child: SizedBox(
                width: context.r(28),
                height: context.r(28),
                child: Image.asset('assets/media/book1.jpg', fit: BoxFit.cover),
              ),
            )
          else
            SizedBox(width: context.r(28)),
          SizedBox(width: AppSpacing.xs(context) + context.r(3)),
        ],
        Flexible(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.78,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: fromCompanion
                    ? AppColors.surface
                    : const Color(0xFF2B1A12),
                borderRadius: radius,
                border: Border.all(
                  color: fromCompanion
                      ? AppColors.border
                      : const Color(0x3DFF9E6B),
                  width: 0.5,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.r(12),
                  vertical: context.r(9),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: fromCompanion
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.end,
                  children: [
                    ChatMessageContent(
                      text: message.text,
                      maxLines: 6,
                      style: AppTextStyles.body(context).copyWith(
                        fontSize: context.sp(13.5),
                        height: 1.6,
                        color: fromCompanion
                            ? AppColors.inkSecondary
                            : const Color(0xFFF6E8DC),
                      ),
                    ),
                    if (!fromCompanion && showRead) ...[
                      SizedBox(height: context.r(2)),
                      Text(
                        '已读',
                        style: AppTextStyles.micro(context).copyWith(
                          fontSize: context.sp(9),
                          color: AppColors.inkFaint,
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
