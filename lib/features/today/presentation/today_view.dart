import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/contract/companion_state.dart';
import '../../../core/contract/contract_format.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/responsive/responsive.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_sheet.dart';
import '../../../shared/widgets/fade_mask.dart';
import '../../../shared/widgets/phone_page.dart';
import '../../../shared/widgets/screen_header.dart';
import '../data/companion_state_mapper.dart';
import 'widgets/now_card.dart';
import 'widgets/timeline_card.dart';
import 'widgets/today_header_actions.dart';

class TodayView extends ConsumerWidget {
  const TodayView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(companionStateProvider);
    return PhonePage(
      key: const Key('today_view'),
      header: ScreenHeader(
        title: '今天',
        subtitle: todaySubtitle(state.valueOrNull),
        actions: const [TodayHeaderActions()],
      ),
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(companionStateProvider),
        ),
        data: (data) =>
            _TodayBody(state: data, onOpenNow: () => _showNow(context, data)),
      ),
    );
  }

  void _showNow(BuildContext context, CompanionState state) {
    showAppSheet(
      context,
      title: '他此刻',
      child: _NowSheet(state: state),
    );
  }
}

/// 单页内容：他此刻 + 时间线，全部平铺在页面底色上，没有卡片套卡片。
class _TodayBody extends StatelessWidget {
  const _TodayBody({required this.state, required this.onOpenNow});

  final CompanionState state;
  final VoidCallback onOpenNow;

  @override
  Widget build(BuildContext context) {
    final entries = timelineOf(state);
    final recent = entries.take(4).toList();
    final rest = entries.skip(4).toList();
    return FadeMask(
      child: ListView(
        key: const Key('today_feed'),
        padding: EdgeInsets.fromLTRB(
          AppSpacing.pageH(context),
          context.r(62),
          AppSpacing.pageH(context),
          context.isPortrait ? context.r(112) : AppSpacing.lg(context),
        ),
        children: [
          NowCard(companion: companionOf(state), onTap: onOpenNow),
          SizedBox(height: context.r(8)),
          if (entries.isEmpty)
            const _EmptyHint()
          else ...[
            TimelineCard(
              key: const Key('today_timeline_recent'),
              entries: recent,
            ),
            if (rest.isNotEmpty) ...[
              const _SectionLabel(text: '今天真实发生的事'),
              TimelineCard(
                key: const Key('today_timeline_rest'),
                entries: rest,
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: context.r(12),
        bottom: context.r(7),
        left: context.r(4),
        right: context.r(4),
      ),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
        ),
        child: Padding(
          padding: EdgeInsets.only(top: context.r(10)),
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption(context).copyWith(
              fontSize: context.sp(10.5),
              fontWeight: FontWeight.w500,
              color: AppColors.inkSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint();

  @override
  Widget build(BuildContext context) {
    return Text(
      '今天还没有发生什么。',
      style: AppTextStyles.body(
        context,
      ).copyWith(fontSize: context.sp(12), color: AppColors.inkMuted),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: EdgeInsets.all(AppSpacing.lg(context)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('连不上笨笨', style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: AppSpacing.sm(context)),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          SizedBox(height: AppSpacing.md(context)),
          FilledButton(onPressed: onRetry, child: const Text('重试')),
        ],
      ),
    ),
  );
}

class _NowSheet extends StatelessWidget {
  const _NowSheet({required this.state});

  final CompanionState state;

  @override
  Widget build(BuildContext context) {
    final companion = state.companion;
    final place = companion.place?.name ?? '';
    final transit = transitLabel(companion.transit);
    final where = transit.isNotEmpty
        ? '$place · $transit'
        : (place.isEmpty ? '栖湾' : place);
    final energy = contractPercentLabel(companion.energy) ?? '—';
    final satiety = contractPercentLabel(companion.satiety) ?? '—';
    final mood = contractPercentLabel(companion.mood) ?? '—';
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg(context)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '他现在',
              style: AppTextStyles.title(
                context,
              ).copyWith(fontSize: context.sp(18), fontWeight: FontWeight.w600),
            ),
            SizedBox(height: AppSpacing.sm(context)),
            Text(
              where,
              style: AppTextStyles.headline(
                context,
              ).copyWith(fontSize: context.sp(26), fontWeight: FontWeight.w600),
            ),
            SizedBox(height: AppSpacing.sm(context)),
            Text(
              '精力 $energy · 饱腹 $satiety · 心情 $mood',
              style: AppTextStyles.body(context).copyWith(
                fontSize: context.sp(15),
                fontWeight: FontWeight.w500,
                color: AppColors.ink,
              ),
            ),
            SizedBox(height: AppSpacing.sm(context)),
            Text(
              companion.condition.isEmpty ? '没有特别说明。' : companion.condition,
              style: AppTextStyles.body(
                context,
              ).copyWith(fontSize: context.sp(14), fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
    );
  }
}
