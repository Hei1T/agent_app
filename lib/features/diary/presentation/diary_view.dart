// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';

import '../../../core/responsive/responsive.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/app_icon_button.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/fade_mask.dart';
import '../../../shared/widgets/phone_page.dart';
import '../../../shared/widgets/screen_header.dart';
import '../data/demo_diary.dart';
import '../domain/entities/diary_entry.dart';
import 'widgets/diary_entry_card.dart';

class DiaryView extends StatefulWidget {
  const DiaryView({super.key});

  @override
  State<DiaryView> createState() => _DiaryViewState();
}

class _DiaryViewState extends State<DiaryView> {
  late final List<GlobalKey> _entryKeys = List.generate(
    demoDiary.length,
    (_) => GlobalKey(),
  );

  @override
  Widget build(BuildContext context) {
    return PhonePage(
      key: const Key('diary_view'),
      header: ScreenHeader(
        title: '日记',
        subtitle: '11月1日 — 10月28日',
        actions: [
          AppIconButton(
            icon: AppIconName.calendar,
            onTap: () => _showCalendar(context),
          ),
        ],
      ),
      child: FadeMask(
        child: ListView.separated(
          key: const Key('diary_feed'),
          padding: EdgeInsets.fromLTRB(
            AppSpacing.pageH(context),
            context.r(62),
            AppSpacing.pageH(context),
            context.isPortrait ? context.r(112) : AppSpacing.lg(context),
          ),
          itemCount: demoDiary.length,
          separatorBuilder: (context, index) =>
              SizedBox(height: AppSpacing.md(context)),
          itemBuilder: (context, index) => KeyedSubtree(
            key: _entryKeys[index],
            child: DiaryEntryCard(
              entry: demoDiary[index],
              showDivider: index != demoDiary.length - 1,
            ),
          ),
        ),
      ),
    );
  }

  void _showCalendar(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _DiaryCalendarSheet(
        entries: demoDiary,
        onPick: (index) {
          if (!mounted) return;
          Navigator.of(context).pop();
          Future<void>.delayed(const Duration(milliseconds: 220), () {
            if (!mounted) return;
            final target = _entryKeys[index].currentContext;
            if (target != null) {
              Scrollable.ensureVisible(
                target,
                duration: const Duration(milliseconds: 420),
                curve: Curves.easeOutCubic,
                alignment: 0.02,
              );
            }
          });
        },
      ),
    );
  }
}

class _DiaryCalendarSheet extends StatelessWidget {
  const _DiaryCalendarSheet({required this.entries, required this.onPick});

  final List<DiaryEntry> entries;
  final ValueChanged<int> onPick;

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
            Text('跳到某一天', style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: AppSpacing.sm(context)),
            for (var i = 0; i < entries.length; i++)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('${entries[i].date} · ${entries[i].weekday}'),
                subtitle: Text('${entries[i].weather} · ${entries[i].mood}'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => onPick(i),
              ),
          ],
        ),
      ),
    );
  }
}
