import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/app_providers.dart';
import '../../core/responsive/responsive.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'app_icon.dart';
import 'media_text.dart';

/// 顶层主动消息：core 的 TurnOutput(source=proactive/life_sim/attention)
/// 经 WS 到达后显示；点击进入对话，关闭只清通知。
class ProactiveNotice extends ConsumerWidget {
  const ProactiveNotice({super.key, this.onOpen});

  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notice = ref.watch(proactiveNoticeProvider);
    if (notice == null) return const SizedBox.shrink();
    final radius = BorderRadius.circular(context.r(20));
    final open = onOpen ?? () => context.go('/chat');
    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.r(9),
        context.r(10),
        context.r(9),
        0,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: const Color(0x57FFB783)),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFA30231C), Color(0xFA17100D)],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x9E000000),
                blurRadius: 64,
                offset: Offset(0, 24),
              ),
            ],
          ),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              ref.read(proactiveNoticeProvider.notifier).dismiss();
              open();
            },
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                context.r(15),
                context.r(14),
                context.r(15),
                context.r(13),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Avatar(),
                  SizedBox(width: context.r(11)),
                  Expanded(
                    child: _Main(
                      text: notice.text,
                      onReply: () {
                        ref.read(proactiveNoticeProvider.notifier).dismiss();
                        open();
                      },
                    ),
                  ),
                  SizedBox(width: context.r(11)),
                  GestureDetector(
                    onTap: () =>
                        ref.read(proactiveNoticeProvider.notifier).dismiss(),
                    child: Container(
                      width: context.r(24),
                      height: context.r(24),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0x12FFFFFF),
                      ),
                      child: Center(
                        child: AppIcon(
                          AppIconName.close,
                          size: context.r(10),
                          color: const Color(0x85F7F2EB),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.r(42),
      height: context.r(42),
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0x21FF9E6B),
          border: Border.all(color: const Color(0x85FF9E6B)),
        ),
        child: Center(
          child: Text(
            '笨',
            style: AppTextStyles.bodyStrong(
              context,
            ).copyWith(color: AppColors.tint, fontSize: context.sp(14)),
          ),
        ),
      ),
    );
  }
}

class _Main extends StatelessWidget {
  const _Main({required this.text, required this.onReply});

  final String text;
  final VoidCallback onReply;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '笨笨',
              style: AppTextStyles.bodyStrong(context).copyWith(
                fontSize: context.sp(10.5),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
                color: AppColors.ink,
              ),
            ),
            SizedBox(width: context.r(7)),
            _Tag(),
            const Spacer(),
            Text(
              '刚刚',
              style: AppTextStyles.micro(
                context,
              ).copyWith(fontSize: context.sp(7)),
            ),
          ],
        ),
        SizedBox(height: context.r(6)),
        MediaRichText(
          text: text,
          maxLines: 3,
          maxMediaHeight: 140,
          style: AppTextStyles.body(context).copyWith(
            fontSize: context.sp(10.5),
            height: 1.55,
            color: const Color(0xD6F7F2EB),
          ),
        ),
        SizedBox(height: context.r(9)),
        Container(
          padding: EdgeInsets.only(top: context.r(8)),
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Color(0x13FFFFFF), width: 0.5),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '他在等你回一句',
                  style: AppTextStyles.micro(
                    context,
                  ).copyWith(fontSize: context.sp(7.5), letterSpacing: 0.3),
                ),
              ),
              _Reply(onTap: onReply),
            ],
          ),
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.r(6),
        vertical: context.r(2),
      ),
      decoration: BoxDecoration(
        color: const Color(0x1AFF9E6B),
        borderRadius: BorderRadius.circular(context.r(999)),
        border: Border.all(color: const Color(0x40FFB783), width: 0.5),
      ),
      child: Text(
        '主动消息',
        style: AppTextStyles.micro(context).copyWith(
          fontSize: context.sp(7),
          letterSpacing: 0.6,
          color: const Color(0xD1FFB783),
        ),
      ),
    );
  }
}

class _Reply extends StatelessWidget {
  const _Reply({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.r(11),
          vertical: context.r(5),
        ),
        decoration: BoxDecoration(
          color: const Color(0x29FF9E6B),
          borderRadius: BorderRadius.circular(context.r(999)),
          border: Border.all(color: const Color(0x57FFB783), width: 0.5),
        ),
        child: Text(
          '回他',
          style: AppTextStyles.micro(context).copyWith(
            fontSize: context.sp(8),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
            color: AppColors.tint,
          ),
        ),
      ),
    );
  }
}
