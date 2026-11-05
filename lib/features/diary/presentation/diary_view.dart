// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/contract/contract_format.dart';
import '../../../core/contract/diary.dart';
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
import '../../../shared/widgets/screen_header.dart';
import 'widgets/diary_entry_card.dart';

class DiaryView extends ConsumerStatefulWidget {
  const DiaryView({super.key});

  @override
  ConsumerState<DiaryView> createState() => _DiaryViewState();
}

class _DiaryViewState extends ConsumerState<DiaryView> {
  List<GlobalKey> _entryKeys = const [];

  void _syncKeys(int count) {
    if (_entryKeys.length == count) return;
    _entryKeys = List.generate(count, (_) => GlobalKey());
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(diaryProvider);
    final entries = async.valueOrNull?.items ?? const <DiaryEntry>[];
    _syncKeys(entries.length);
    return PhonePage(
      key: const Key('diary_view'),
      header: ScreenHeader(
        title: '日记',
        subtitle: _subtitle(entries),
        actions: [
          AppIconButton(
            icon: AppIconName.calendar,
            onTap: () {
              if (entries.isEmpty) return;
              _showCalendar(context, entries);
            },
          ),
        ],
      ),
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(diaryProvider),
        ),
        data: (page) => page.items.isEmpty
            ? const _EmptyState()
            : _DiaryList(entries: page.items, entryKeys: _entryKeys),
      ),
    );
  }

  String _subtitle(List<DiaryEntry> entries) {
    if (entries.isEmpty) return '还没有日记';
    String labelOf(DiaryEntry entry) =>
        contractDateLabel(entry.day) ??
        contractDateLabel(entry.createdAt) ??
        '';
    final last = labelOf(entries.last);
    final first = labelOf(entries.first);
    final parts = [last, first].where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) return '他写下的日子';
    if (parts.length == 1 || parts.first == parts.last) return parts.first;
    return '${parts[0]} — ${parts[1]}';
  }

  void _showCalendar(BuildContext context, List<DiaryEntry> entries) {
    showAppSheet(
      context,
      title: '跳到某一天',
      child: _DiaryCalendarSheet(
        entries: entries,
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

class _DiaryList extends StatelessWidget {
  const _DiaryList({required this.entries, required this.entryKeys});

  final List<DiaryEntry> entries;
  final List<GlobalKey> entryKeys;

  @override
  Widget build(BuildContext context) {
    return FadeMask(
      child: ListView.separated(
        key: const Key('diary_feed'),
        padding: EdgeInsets.fromLTRB(
          AppSpacing.pageH(context),
          context.r(62),
          AppSpacing.pageH(context),
          context.isPortrait ? context.r(112) : AppSpacing.lg(context),
        ),
        itemCount: entries.length,
        separatorBuilder: (context, index) =>
            SizedBox(height: AppSpacing.md(context)),
        itemBuilder: (context, index) => KeyedSubtree(
          key: index < entryKeys.length ? entryKeys[index] : null,
          child: DiaryEntryCard(
            entry: entries[index],
            showDivider: index != entries.length - 1,
          ),
        ),
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
        '他还没有写过日记。',
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
            Text('日记暂时连不上', style: Theme.of(context).textTheme.titleMedium),
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
                title: Text(
                  [
                    contractDateLabel(entries[i].day) ?? '某一天',
                    contractWeekdayLabel(
                          entries[i].day ?? entries[i].createdAt,
                        ) ??
                        '',
                  ].where((part) => part.isNotEmpty).join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  entries[i].text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => onPick(i),
              ),
          ],
        ),
      ),
    );
  }
}
