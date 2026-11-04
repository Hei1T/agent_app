import 'package:flutter/material.dart';

import '../../../core/responsive/responsive.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/models/companion.dart';
import '../../../shared/widgets/fade_mask.dart';
import '../../../shared/widgets/phone_page.dart';
import '../../../shared/widgets/screen_header.dart';
import '../data/demo_today.dart';
import 'widgets/now_card.dart';
import 'widgets/timeline_card.dart';
import 'widgets/today_header_actions.dart';

class TodayView extends StatefulWidget {
  const TodayView({super.key});

  @override
  State<TodayView> createState() => _TodayViewState();
}

class _TodayViewState extends State<TodayView> {
  @override
  Widget build(BuildContext context) {
    return PhonePage(
      key: const Key('today_view'),
      header: ScreenHeader(
        title: '今天',
        subtitle: '11月2日 周日 · 雨 1.7°C',
        actions: const [TodayHeaderActions()],
      ),
      child: FadeMask(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.pageH(context),
            context.r(62),
            AppSpacing.pageH(context),
            context.isPortrait ? context.r(112) : AppSpacing.lg(context),
          ),
          children: [
            NowCard(companion: demoCompanion, onTap: _showNow),
            SizedBox(height: AppSpacing.sm(context)),
            TimelineCard(entries: demoTodayTimeline.take(4).toList()),
            SizedBox(height: AppSpacing.md(context)),
            _SectionLabel(text: '上午'),
            SizedBox(height: AppSpacing.xs(context)),
            TimelineCard(entries: demoTodayTimeline.skip(4).toList()),
          ],
        ),
      ),
    );
  }

  void _showNow() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const _NowSheet(),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxs(context)),
      child: Text(text, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}

class _NowSheet extends StatelessWidget {
  const _NowSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg(context)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('他此刻', style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: AppSpacing.sm(context)),
            Text('在旧书店 · 收书', style: Theme.of(context).textTheme.headlineSmall),
            SizedBox(height: AppSpacing.sm(context)),
            Text(
              '这是他自己的第 5 天。他的生活只在这个窗口里继续。',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
