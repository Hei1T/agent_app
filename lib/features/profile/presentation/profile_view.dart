import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/contract/companion_state.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/responsive/responsive.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/models/companion.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/app_icon_button.dart';
import '../../../shared/widgets/app_sheet.dart';
import '../../../shared/widgets/fade_mask.dart';
import '../../../shared/widgets/phone_page.dart';
import '../../../shared/widgets/screen_header.dart';
import '../../today/data/companion_state_mapper.dart';
import '../data/profile_mapper.dart';
import '../domain/entities/profile_data.dart';
import 'widgets/profile_hero.dart';
import 'widgets/profile_section.dart';

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  void _showMore(BuildContext context) {
    showAppSheet(
      context,
      title: '关于他',
      child: SheetActionsWidget(
        actions: const [
          SheetActionData(
            id: 'share',
            label: '分享他的主页',
            description: '让朋友看看他',
            icon: AppIconName.send,
          ),
          SheetActionData(
            id: 'copy',
            label: '复制名字',
            description: '笨笨',
            icon: AppIconName.person,
          ),
          SheetActionData(
            id: 'settings',
            label: '设置',
            description: '通知、显示与关于',
            icon: AppIconName.settings,
          ),
          SheetActionData(
            id: 'about',
            label: '关于笨笨',
            description: '栖湾 · 旧书店',
            icon: AppIconName.book,
          ),
        ],
        onPick: (_) => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(companionStateProvider);
    final state = async.valueOrNull;
    final companion = state == null ? null : companionOf(state);
    final subtitle = companion == null
        ? '正在连到他…'
        : (companion.place.isEmpty ? '栖湾' : '栖湾 · ${companion.place}');
    return PhonePage(
      key: const Key('profile_view'),
      header: ScreenHeader(
        title: '他',
        subtitle: subtitle,
        actions: [
          AppIconButton(
            icon: AppIconName.more,
            onTap: () => _showMore(context),
          ),
        ],
      ),
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(companionStateProvider),
        ),
        data: (data) => _ProfileBody(state: data, companion: companionOf(data)),
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({required this.state, required this.companion});

  final CompanionState state;
  final Companion companion;

  @override
  Widget build(BuildContext context) {
    final profile = profileOf(state);
    return FadeMask(
      child: ListView(
        key: const Key('profile_feed'),
        padding: EdgeInsets.fromLTRB(
          AppSpacing.pageH(context),
          context.r(62),
          AppSpacing.pageH(context),
          context.isPortrait ? context.r(112) : AppSpacing.lg(context),
        ),
        children: [
          ProfileHero(companion: companion),
          SizedBox(height: AppSpacing.md(context)),
          if (companion.quote.isNotEmpty) ...[
            _QuoteCard(companion: companion),
            SizedBox(height: AppSpacing.md(context)),
          ],
          _ProfileTiles(
            state: state,
            people: profile.people,
            things: profile.things,
          ),
          SizedBox(height: AppSpacing.md(context)),
          // TODO(app-contract): 朋友圈 / 日记 media 接口接入后换成后端照片。
          const ProfileSection(
            key: Key('profile_section_photos'),
            title: '最近拍下的',
            child: _PhotoRow(),
          ),
          SizedBox(height: AppSpacing.md(context)),
          ProfileSection(
            key: const Key('profile_section_people'),
            title: '他记得的人',
            meta: '${profile.people.length} 个街坊',
            child: _PeopleList(people: profile.people),
          ),
          SizedBox(height: AppSpacing.md(context)),
          ProfileSection(
            key: const Key('profile_section_things'),
            title: '他的家当',
            meta: '${profile.things.length} 件',
            child: _ThingsList(things: profile.things),
          ),
          SizedBox(height: AppSpacing.md(context)),
          const ProfileSection(
            key: Key('profile_section_days'),
            title: '更早的日子',
            child: _DayStrip(),
          ),
        ],
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
            Text('连不上他', style: Theme.of(context).textTheme.titleMedium),
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

class _PhotoRow extends StatelessWidget {
  const _PhotoRow();

  static const _photos = [
    'assets/media/book1.jpg',
    'assets/media/book2.jpg',
    'assets/media/book3.jpg',
    'assets/media/book1.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.r(64),
      child: Row(
        children: [
          for (var i = 0; i < _photos.length; i++) ...[
            if (i > 0) SizedBox(width: context.r(6)),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.sm(context)),
                child: Opacity(
                  opacity: 0.92,
                  child: Image.asset(
                    _photos[i],
                    fit: BoxFit.cover,
                    cacheWidth: 400,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PeopleList extends StatelessWidget {
  const _PeopleList({required this.people});

  final List<Person> people;

  @override
  Widget build(BuildContext context) {
    if (people.isEmpty) return const _EmptyHint(text: '还没有记住的人。');
    return Column(
      children: [
        for (var i = 0; i < people.length; i++)
          _PersonRow(person: people[i], showDivider: i != people.length - 1),
      ],
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.caption(
        context,
      ).copyWith(fontSize: context.sp(11), color: AppColors.inkMuted),
    );
  }
}

class _PersonRow extends StatelessWidget {
  const _PersonRow({required this.person, required this.showDivider});

  final Person person;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: context.r(7)),
      decoration: showDivider
          ? const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.divider)),
            )
          : null,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm(context)),
            child: SizedBox(
              width: context.r(30),
              height: context.r(30),
              child: Image.asset(
                person.photo,
                fit: BoxFit.cover,
                cacheWidth: 160,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.sm(context)),
          Expanded(child: _PersonText(person: person)),
          AppIcon(
            AppIconName.chevron,
            size: context.r(14),
            color: AppColors.inkFaint,
          ),
        ],
      ),
    );
  }
}

class _PersonText extends StatelessWidget {
  const _PersonText({required this.person});

  final Person person;

  @override
  Widget build(BuildContext context) {
    final note = person.note.isEmpty
        ? person.role
        : '${person.role} · ${person.note}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          person.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.bodyStrong(
            context,
          ).copyWith(fontSize: context.sp(13), color: AppColors.ink),
        ),
        Text(
          note,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.caption(
            context,
          ).copyWith(fontSize: context.sp(10.5), color: AppColors.inkMuted),
        ),
      ],
    );
  }
}

class _ThingsList extends StatelessWidget {
  const _ThingsList({required this.things});

  final List<Thing> things;

  static const _icons = [
    AppIconName.book,
    AppIconName.sun,
    AppIconName.moments,
  ];

  @override
  Widget build(BuildContext context) {
    if (things.isEmpty) return const _EmptyHint(text: '还没有记下的家当。');
    return Column(
      children: [
        for (var i = 0; i < things.length; i++)
          _ThingRow(
            thing: things[i],
            icon: _icons[i % _icons.length],
            showDivider: i != things.length - 1,
          ),
      ],
    );
  }
}

class _ThingRow extends StatelessWidget {
  const _ThingRow({
    required this.thing,
    required this.icon,
    required this.showDivider,
  });

  final Thing thing;
  final AppIconName icon;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: context.r(7)),
      decoration: showDivider
          ? const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.divider)),
            )
          : null,
      child: Row(
        children: [
          Container(
            width: context.r(30),
            height: context.r(30),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(AppRadius.sm(context)),
            ),
            child: AppIcon(
              icon,
              size: context.r(16),
              color: AppColors.inkMuted,
            ),
          ),
          SizedBox(width: AppSpacing.sm(context)),
          Expanded(child: _ThingText(thing: thing)),
          AppIcon(
            AppIconName.chevron,
            size: context.r(14),
            color: AppColors.inkFaint,
          ),
        ],
      ),
    );
  }
}

class _ThingText extends StatelessWidget {
  const _ThingText({required this.thing});

  final Thing thing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          thing.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.bodyStrong(
            context,
          ).copyWith(fontSize: context.sp(13), color: AppColors.ink),
        ),
        Text(
          thing.detail,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.caption(
            context,
          ).copyWith(fontSize: context.sp(10.5), color: AppColors.inkMuted),
        ),
      ],
    );
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({required this.companion});

  final Companion companion;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('profile_quote_card'),
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: context.r(14),
        vertical: context.r(12),
      ),
      decoration: BoxDecoration(
        color: AppColors.tint.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(context.r(16)),
        border: Border.all(color: AppColors.tint.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '他最近说',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.micro(context).copyWith(
              fontSize: context.sp(10.5),
              letterSpacing: 1,
              color: AppColors.inkFaint,
            ),
          ),
          SizedBox(height: AppSpacing.xs(context)),
          Text(
            '“${companion.quote}”',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body(context).copyWith(
              fontSize: context.sp(14.5),
              height: 1.6,
              color: AppColors.ink,
            ),
          ),
          if (companion.quoteMeta.isNotEmpty) ...[
            SizedBox(height: AppSpacing.xs(context)),
            Text(
              companion.quoteMeta,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption(
                context,
              ).copyWith(fontSize: context.sp(10.5), color: AppColors.inkFaint),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProfileTiles extends StatelessWidget {
  const _ProfileTiles({
    required this.state,
    required this.people,
    required this.things,
  });

  final CompanionState state;
  final List<Person> people;
  final List<Thing> things;

  @override
  Widget build(BuildContext context) {
    final latest = state.events.isEmpty ? null : state.events.first;
    final peopleNames = people
        .map((person) => person.name)
        .where((name) => name.isNotEmpty)
        .take(3)
        .join(' · ');
    final thingNames = things
        .map((thing) => thing.name)
        .where((name) => name.isNotEmpty)
        .take(3)
        .join(' · ');
    final place = state.companion.place?.name ?? '';
    final tiles = [
      _TileData('见过的人', '${people.length}', peopleNames),
      _TileData('他的物件', '${things.length}', thingNames),
      _TileData(
        '今天的事',
        '${state.events.length}',
        latest == null
            ? ''
            : (latest.title.isEmpty ? latest.detail : latest.title),
      ),
      _TileData(
        '这些天',
        state.companion.day?.toString() ?? '—',
        place.isEmpty ? '在栖湾' : '在$place',
      ),
    ];
    final gap = AppSpacing.sm(context);
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _Tile(data: tiles[0])),
            SizedBox(width: gap),
            Expanded(child: _Tile(data: tiles[1])),
          ],
        ),
        SizedBox(height: gap),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _Tile(data: tiles[2])),
            SizedBox(width: gap),
            Expanded(child: _Tile(data: tiles[3])),
          ],
        ),
      ],
    );
  }
}

class _TileData {
  const _TileData(this.label, this.value, this.detail);

  final String label;
  final String value;
  final String detail;
}

class _Tile extends StatelessWidget {
  const _Tile({required this.data});

  final _TileData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.r(11),
        vertical: context.r(10),
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md(context)),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption(
              context,
            ).copyWith(fontSize: context.sp(10.5), color: AppColors.inkFaint),
          ),
          SizedBox(height: context.r(1)),
          Text(
            data.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.title(context).copyWith(
              fontSize: context.sp(18),
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          SizedBox(height: context.r(2)),
          Text(
            data.detail,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption(
              context,
            ).copyWith(fontSize: context.sp(10.5), color: AppColors.inkMuted),
          ),
        ],
      ),
    );
  }
}

class _DayStrip extends StatelessWidget {
  const _DayStrip();

  @override
  Widget build(BuildContext context) {
    // TODO(app-contract): 等日记 API 返回真实照片后，替换成最近几天的真实缩略图。
    return SizedBox(
      height: context.r(62),
      child: Row(
        children: [
          for (var i = 0; i < 5; i++) ...[
            if (i > 0) SizedBox(width: context.r(6)),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.sm(context)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      i.isEven
                          ? 'assets/media/book1.jpg'
                          : 'assets/media/book2.jpg',
                      fit: BoxFit.cover,
                      cacheWidth: 300,
                    ),
                    Positioned(
                      left: context.r(5),
                      bottom: context.r(5),
                      child: Text(
                        '10/${24 + i}',
                        style: TextStyle(
                          fontSize: context.sp(10),
                          fontWeight: FontWeight.w500,
                          color: AppColors.ink,
                          shadows: [
                            Shadow(
                              color: AppColors.ground.withValues(alpha: 0.8),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
