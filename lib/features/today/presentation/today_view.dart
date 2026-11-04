import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/auth/auth_controller.dart';
import '../../../core/responsive/responsive.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/models/companion.dart';
import '../../../shared/widgets/fade_mask.dart';
import '../../../shared/widgets/phone_page.dart';
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
        subtitle: life.valueOrNull == null ? '正在连到栖湾…' : '${life.value!.clock} · ${life.value!.weather}',
        actions: const [TodayHeaderActions()],
      ),
      child: life.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(message: error.toString(), onRetry: () => ref.invalidate(lifeProvider)),
        data: (snapshot) => FadeMask(
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.pageH(context), context.r(62), AppSpacing.pageH(context),
              context.isPortrait ? context.r(112) : AppSpacing.lg(context),
            ),
            children: [
              NowCard(companion: _toCompanion(snapshot), onTap: () => _showNow(context, snapshot)),
              SizedBox(height: AppSpacing.sm(context)),
              TimelineCard(entries: _timeline(snapshot).take(4).toList()),
              SizedBox(height: AppSpacing.md(context)),
              _SectionLabel(text: '今天真实发生的事'),
              SizedBox(height: AppSpacing.xs(context)),
              if (snapshot.events.isEmpty)
                Text('今天还没有发生什么。', style: Theme.of(context).textTheme.bodySmall)
              else
                TimelineCard(entries: _timeline(snapshot).skip(4).toList()),
            ],
          ),
        ),
      ),
    );
  }

  Companion _toCompanion(LifeSnapshot life) => Companion(
    name: '笨笨', day: 1, place: life.place,
    action: life.transit == null ? '在这儿' : '在路上',
    weather: life.weather, temperature: '', energy: (life.energy * 100).round(),
    mood: life.mood > 0.65 ? '还行' : '安静', awake: life.awake, lastSeen: life.clock,
  );

  List<TimelineEntry> _timeline(LifeSnapshot life) => [
    for (var i = 0; i < life.events.length; i++)
      TimelineEntry(
        id: 'evt-$i', time: life.events[i].time,
        title: '笨笨 · ${life.events[i].feeling.isEmpty ? '生活' : life.events[i].feeling}',
        detail: life.events[i].detail,
        photo: 'assets/media/book1.jpg',
        feeling: life.events[i].feeling,
      ),
  ];

  void _showNow(BuildContext context, LifeSnapshot life) {
    showModalBottomSheet<void>(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (context) => _NowSheet(life: life),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxs(context)),
    child: Text(text, style: Theme.of(context).textTheme.labelSmall),
  );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: EdgeInsets.all(AppSpacing.lg(context)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('连不上笨笨', style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: AppSpacing.sm(context)),
        Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
        SizedBox(height: AppSpacing.md(context)),
        FilledButton(onPressed: onRetry, child: const Text('重试')),
      ]),
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
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('他现在', style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: AppSpacing.sm(context)),
        Text(life.place + (life.transit == null ? '' : ' · 在路上'), style: Theme.of(context).textTheme.headlineSmall),
        SizedBox(height: AppSpacing.sm(context)),
        Text('精力 ${(life.energy * 100).round()}% · 饱腹 ${(life.satiety * 100).round()}% · 心情 ${(life.mood * 100).round()}%', style: Theme.of(context).textTheme.bodyMedium),
        SizedBox(height: AppSpacing.sm(context)),
        Text(life.condition.isEmpty ? '这是他自己的第 1 天。' : life.condition, style: Theme.of(context).textTheme.bodySmall),
      ]),
    ),
  );
}
