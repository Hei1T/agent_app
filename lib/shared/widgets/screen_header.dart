import 'package:flutter/material.dart';

import '../../core/responsive/responsive.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'glass_panel.dart';

class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions = const [],
    this.compact = false,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget> actions;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      key: const Key('screen_header'),
      padding: EdgeInsets.symmetric(
        horizontal: context.isPortrait ? context.r(10) : AppSpacing.md(context),
        vertical: 0,
      ),
      borderRadius: BorderRadius.circular(AppRadius.lg(context)),
      child: SizedBox(
        height: context.r(compact ? 38 : 46),
        child: Row(
          children: [
            if (leading != null) ...[
              leading!,
              SizedBox(width: AppSpacing.xs(context)),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyStrong(
                      context,
                    ).copyWith(fontSize: context.sp(14)),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption(
                        context,
                      ).copyWith(fontSize: context.sp(8.5)),
                    ),
                ],
              ),
            ),
            for (final action in actions) ...[
              SizedBox(width: AppSpacing.xxs(context)),
              action,
            ],
          ],
        ),
      ),
    );
  }
}
