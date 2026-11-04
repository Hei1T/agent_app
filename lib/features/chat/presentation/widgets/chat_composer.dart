import 'package:flutter/material.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// 竖屏里由 Dock 变来的输入栏：胶囊从 252 展开到全宽，发送圆最后出现。
class ChatComposer extends StatelessWidget {
  const ChatComposer({
    super.key,
    required this.controller,
    required this.onSend,
  });

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.pageH(context),
          AppSpacing.xs(context),
          AppSpacing.pageH(context),
          AppSpacing.sm(context),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final fullBar =
                constraints.maxWidth - context.r(44) - AppSpacing.sm(context);
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 380),
              curve: Curves.easeOutCubic,
              builder: (context, t, _) {
                final barWidth =
                    context.r(252) + (fullBar - context.r(252)) * t;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: barWidth,
                      height: context.r(48),
                      child: Opacity(
                        opacity: (t * 1.6).clamp(0.0, 1.0).toDouble(),
                        child: _ComposerPill(
                          controller: controller,
                          onSend: onSend,
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm(context) * t),
                    Opacity(
                      opacity: t,
                      child: GestureDetector(
                        onTap: onSend,
                        child: Container(
                          width: context.r(44),
                          height: context.r(44),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.surface,
                            border: Border.all(
                              color: AppColors.border,
                              width: 0.5,
                            ),
                          ),
                          child: Icon(
                            Icons.arrow_upward_rounded,
                            size: context.r(18),
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ComposerPill extends StatelessWidget {
  const _ComposerPill({required this.controller, required this.onSend});

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.r(48),
      padding: EdgeInsets.symmetric(horizontal: context.r(14)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(context.r(999)),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            size: context.r(16),
            color: AppColors.inkFaint,
          ),
          SizedBox(width: context.r(9)),
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: 1,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              style: TextStyle(
                color: AppColors.ink,
                fontSize: context.sp(13),
                height: 1.3,
              ),
              decoration: const InputDecoration(
                hintText: '跟他说点什么...',
                hintStyle: TextStyle(color: AppColors.inkFaint),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          SizedBox(width: context.r(9)),
          Icon(
            Icons.camera_alt_outlined,
            size: context.r(18),
            color: AppColors.inkFaint,
          ),
        ],
      ),
    );
  }
}
