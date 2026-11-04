import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/auth/auth_controller.dart';
import '../../../core/responsive/responsive.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/models/companion.dart';
import '../../../shared/widgets/fade_mask.dart';
import '../../../shared/widgets/phone_page.dart';
import '../../../shared/widgets/app_sheet.dart';
import '../../../shared/widgets/screen_header.dart';
import '../domain/entities/today_entities.dart';
import 'widgets/now_card.dart';
import 'widgets/timeline_card.dart';
import 'widgets/today_header_actions.dart';

class TodayView extends ConsumerWidget {
  const TodayView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final life = ref.watch(lifeProvider);
    return PhonePage(
      key: const Key('today_view'),
      header: ScreenHeader(
        title: '今天',
        subtitle: _subtitle(life.valueOrNull),
        actions: const [TodayHeaderActions()],
      ),
      child: life.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(lifeProvider),
        ),
        data: (snapshot) => _TodayBody(
          snapshot: snapshot,
          onOpenNow: () => _showNow(context, snapshot),
        ),
      ),
    );
  }

  void _showNow(BuildContext context, LifeSnapshot life) {
    showAppSheet(
      context,
      title: '他此刻',
      child: _NowSheet(life: life),
    );
  }
}

String _subtitle(LifeSnapshot? life) {
  if (life == null) return '正在连到栖湾…';
  final parts = [life.clock, life.weather].where((part) => part.isNotEmpty);
  return parts.isEmpty ? '正在连到栖湾…' : parts.join(' · ');
}

Companion _companionOf(LifeSnapshot life) => Companion(
  name: '笨笨',
  day: 5,
  place: life.place,
  action: life.transit == null ? '在这儿' : '在路上',
  weather: life.weather,
  temperature: '',
  energy: (life.energy * 100).round(),
  mood: life.mood > 0.65 ? '还行' : '安静',
  awake: life.awake,
  lastSeen: life.clock,
);

List<TimelineEntry> _timelineOf(LifeSnapshot life) => [
  for (var i = 0; i < life.events.length; i++)
    TimelineEntry(
      id: 'evt-$i',
      time: life.events[i].time,
      title: '笨笨 · ${_eventLabel(i, life.events[i].feeling)}',
      detail: life.events[i].detail,
      photo: _eventPhoto(i),
      feeling: life.events[i].feeling,
      unread: i == 0
          ? 2
          : i == 1
          ? 1
          : 0,
    ),
];

/// 单页内容：他此刻 + 时间线，全部平铺在页面底色上，没有卡片套卡片。
class _TodayBody extends StatelessWidget {
  const _TodayBody({required this.snapshot, required this.onOpenNow});

  final LifeSnapshot snapshot;
  final VoidCallback onOpenNow;

  @override
  Widget build(BuildContext context) {
    final entries = _timelineOf(snapshot);
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
          NowCard(companion: _companionOf(snapshot), onTap: onOpenNow),
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
  const _NowSheet({required this.life});
  final LifeSnapshot life;
  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: EdgeInsets.all(AppSpacing.lg(context)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('他现在', style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: AppSpacing.sm(context)),
          Text(
            life.place + (life.transit == null ? '' : ' · 在路上'),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: AppSpacing.sm(context)),
          Text(
            '精力 ${(life.energy * 100).round()}% · 饱腹 ${(life.satiety * 100).round()}% · 心情 ${(life.mood * 100).round()}%',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: AppSpacing.sm(context)),
          Text(
            life.condition.isEmpty ? '没有特别说明。' : life.condition,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    ),
  );
}

String _eventPhoto(int index) {
  const photos = [
    'assets/media/book1.jpg',
    'assets/media/book2.jpg',
    'assets/media/book3.jpg',
  ];
  return photos[index % photos.length];
}

String _eventLabel(int index, String feeling) {
  if (feeling.isNotEmpty) return feeling;
  const labels = ['收书', '晒太阳', '晒书', '捆杂志'];
  return labels[index % labels.length];
}
