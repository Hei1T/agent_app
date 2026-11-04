import 'package:flutter/material.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

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
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: '跟他说点什么...',
                  hintStyle: const TextStyle(color: AppColors.inkFaint),
                  filled: true,
                  fillColor: AppColors.surfaceRaised,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppRadius.pill(context),
                    ),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppRadius.pill(context),
                    ),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md(context),
                    vertical: AppSpacing.sm(context),
                  ),
                ),
              ),
            ),
            SizedBox(width: AppSpacing.sm(context)),
            GestureDetector(
              onTap: onSend,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.tint,
                ),
                child: SizedBox(
                  width: context.r(42),
                  height: context.r(42),
                  child: Icon(
                    Icons.arrow_upward_rounded,
                    size: context.r(20),
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
