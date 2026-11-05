import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/contract/moment.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/responsive/responsive.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/app_icon_button.dart';
import '../../../shared/widgets/app_sheet.dart';
import '../../../shared/widgets/fade_mask.dart';
import '../../../shared/widgets/phone_page.dart';
import '../../../shared/widgets/photo_overlay.dart';
import '../../../shared/widgets/screen_header.dart';
import 'moments_controller.dart';
import 'widgets/moment_card.dart';
import 'widgets/moment_detail_sheet.dart';

class MomentsView extends ConsumerWidget {
  const MomentsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPage = ref.watch(momentsProvider);
    // 点赞 / 留言状态变化时重建列表。
    ref.watch(momentsControllerProvider);
    final state = ref.watch(companionStateProvider).valueOrNull;
    final day = state?.companion.day;
    return PhonePage(
      key: const Key('moments_view'),
      header: ScreenHeader(
        title: '朋友圈',
        subtitle: day == null ? '他的生活' : '他的生活 · 第 $day 天',
        actions: [
          AppIconButton(
            icon: AppIconName.camera,
            onTap: () => showPhotoPicker(context, withNote: true),
          ),
        ],
      ),
      child: asyncPage.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(momentsProvider),
        ),
        data: (page) {
          if (page.items.isEmpty) return const _EmptyState();
          return _Feed(
            moments: page.items,
            controller: ref.read(momentsControllerProvider.notifier),
            onLike: (moment) => _toggleLike(context, ref, moment),
            onOpen: (moment) => _open(context, ref, moment),
          );
        },
      ),
    );
  }

  Future<void> _toggleLike(
    BuildContext context,
    WidgetRef ref,
    Moment moment,
  ) async {
    final ok = await ref
        .read(momentsControllerProvider.notifier)
        .toggleLike(moment);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('点赞没同步上，已回滚。')));
    }
  }

  void _open(BuildContext context, WidgetRef ref, Moment moment) {
    final controller = ref.read(momentsControllerProvider.notifier);
    showAppSheet(
      context,
      title: '动态',
      full: true,
      showCancel: false,
      fullHeightFactor: 0.82,
      child: MomentDetailSheet(
        moment: moment,
        liked: controller.isLiked(moment),
        comments: controller.commentsFor(moment),
        onLike: () => controller.toggleLike(moment),
        onAddComment: (text) => controller.addComment(moment, text),
      ),
    );
  }
}

/// 朋友圈信息流：每条动态平铺在页面底色上，只有底部分隔线。
class _Feed extends StatelessWidget {
  const _Feed({
    required this.moments,
    required this.controller,
    required this.onLike,
    required this.onOpen,
  });

  final List<Moment> moments;
  final MomentsController controller;
  final ValueChanged<Moment> onLike;
  final ValueChanged<Moment> onOpen;

  @override
  Widget build(BuildContext context) {
    return FadeMask(
      child: ListView.separated(
        key: const Key('moments_feed'),
        padding: EdgeInsets.fromLTRB(
          AppSpacing.pageH(context),
          context.r(62),
          AppSpacing.pageH(context),
          context.isPortrait ? context.r(112) : AppSpacing.lg(context),
        ),
        itemCount: moments.length,
        separatorBuilder: (context, index) => SizedBox(height: context.r(10)),
        itemBuilder: (context, index) {
          final item = moments[index];
          return MomentCard(
            key: ValueKey(item.id),
            moment: item,
            liked: controller.isLiked(item),
            likeCount: controller.likeCount(item),
            comments: controller.commentsFor(item),
            divider: index != moments.length - 1,
            onLike: () => onLike(item),
            onTap: () => onOpen(item),
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '还没有动态',
        style: AppTextStyles.body(
          context,
        ).copyWith(fontSize: context.sp(12), color: AppColors.inkMuted),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg(context)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '朋友圈暂时连不上',
              style: AppTextStyles.body(
                context,
              ).copyWith(fontSize: context.sp(13), color: AppColors.ink),
            ),
            SizedBox(height: AppSpacing.sm(context)),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body(
                context,
              ).copyWith(fontSize: context.sp(12), color: AppColors.inkMuted),
            ),
            SizedBox(height: AppSpacing.md(context)),
            FilledButton(onPressed: onRetry, child: const Text('重试')),
          ],
        ),
      ),
    );
  }
}
