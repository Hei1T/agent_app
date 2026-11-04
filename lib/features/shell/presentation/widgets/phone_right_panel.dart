import 'package:flutter/material.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 手机横屏右侧场景栏：设计稿 RightPanel，照片 + 缩略图条 + 引用 + 他的日子。
class PhoneRightPanel extends StatelessWidget {
  const PhoneRightPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(context.r(22));
    return Padding(
      padding: EdgeInsets.fromLTRB(0, context.r(8), context.r(8), context.r(8)),
      child: ClipRRect(
        borderRadius: radius,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0x8C181210),
            borderRadius: radius,
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/media/book3.jpg',
                      fit: BoxFit.cover,
                      cacheWidth: 900,
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x00080605), Color(0xDB080605)],
                          stops: [0.42, 1],
                        ),
                      ),
                    ),
                    Positioned(
                      left: context.r(14),
                      right: context.r(14),
                      bottom: context.r(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '收书',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.title(
                              context,
                            ).copyWith(fontSize: context.sp(22)),
                          ),
                          SizedBox(height: context.r(3)),
                          Text(
                            '把晒了一下午的旧书一本本收回来，码回后院。',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption(context).copyWith(
                              fontSize: context.sp(10),
                              color: Colors.white70,
                            ),
                          ),
                          SizedBox(height: context.r(3)),
                          Text(
                            '旧书店 · 15:32 · 雨',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.micro(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                color: const Color(0x99120B08),
                padding: EdgeInsets.all(context.r(8)),
                child: SizedBox(
                  height: context.r(48),
                  child: Row(
                    children: [
                      for (var i = 0; i < 3; i++) ...[
                        if (i > 0) SizedBox(width: context.r(6)),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppRadius.sm(context),
                            ),
                            child: Image.asset(
                              i == 0
                                  ? 'assets/media/book1.jpg'
                                  : i == 1
                                  ? 'assets/media/book2.jpg'
                                  : 'assets/media/book3.jpg',
                              fit: BoxFit.cover,
                              cacheWidth: 220,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Container(
                color: const Color(0x99120B08),
                padding: EdgeInsets.fromLTRB(
                  context.r(14),
                  context.r(10),
                  context.r(14),
                  context.r(12),
                ),
                child: Text(
                  '“手上一股子太阳晒过的纸味儿，暖烘烘的。你闻不着，可惜。”',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption(
                    context,
                  ).copyWith(fontSize: context.sp(10), color: Colors.white70),
                ),
              ),
              Container(
                color: const Color(0xB8120B08),
                padding: EdgeInsets.symmetric(vertical: context.r(7)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: context.r(14),
                      color: AppColors.inkFaint,
                    ),
                    SizedBox(width: context.r(4)),
                    Text('他的日子', style: AppTextStyles.micro(context)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
