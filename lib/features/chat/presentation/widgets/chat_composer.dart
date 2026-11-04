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
              child: Container(
                height: context.r(44),
                padding: EdgeInsets.symmetric(horizontal: context.r(14)),
                decoration: BoxDecoration(
                  color: const Color(0xB8140F0D),
                  borderRadius: BorderRadius.circular(context.r(22)),
                  border: Border.all(
                    color: const Color(0x24FFFFFF),
                    width: 0.5,
                  ),
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
                        style: Theme.of(context).textTheme.bodyMedium,
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
              ),
            ),
            SizedBox(width: AppSpacing.sm(context)),
            GestureDetector(
              onTap: onSend,
              child: Container(
                width: context.r(44),
                height: context.r(44),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xB8140F0D),
                  border: Border.all(
                    color: const Color(0x24FFFFFF),
                    width: 0.5,
                  ),
                ),
                child: Icon(
                  Icons.send_rounded,
                  size: context.r(18),
                  color: AppColors.ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
