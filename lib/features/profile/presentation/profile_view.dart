import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_controller.dart';
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
import '../data/demo_profile.dart';
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
    final life = ref.watch(lifeProvider).valueOrNull;
    final people = life == null
        ? demoProfile.people
        : life.people
              .map(
                (p) => Person(
                  name: p.name,
                  role: p.role,
                  note: p.note.isEmpty ? p.place : p.note,
                  photo: 'assets/media/book2.jpg',
                ),
              )
              .toList();
    final things = life == null
        ? demoProfile.things
        : life.items
              .map(
                (item) => Thing(
                  name: (item['kind'] as String?) ?? '物件',
                  detail: (item['note'] as String?) ?? '在他身边',
                ),
              )
              .toList();
    return PhonePage(
      key: const Key('profile_view'),
      header: ScreenHeader(
        title: '他',
        subtitle: '栖湾 · 旧书店',
        actions: [
          AppIconButton(
            icon: AppIconName.more,
            onTap: () => _showMore(context),
          ),
        ],
      ),
      child: FadeMask(
        child: ListView(
          key: const Key('profile_feed'),
          padding: EdgeInsets.fromLTRB(
            AppSpacing.pageH(context),
            context.r(62),
            AppSpacing.pageH(context),
            context.isPortrait ? context.r(112) : AppSpacing.lg(context),
          ),
          children: [
            const ProfileHero(companionName: '笨笨', day: 5),
            SizedBox(height: AppSpacing.md(context)),
            const _QuoteCard(),
            SizedBox(height: AppSpacing.md(context)),
            const _ProfileTiles(),
            SizedBox(height: AppSpacing.md(context)),
            ProfileSection(
              key: const Key('profile_section_photos'),
              title: '最近拍下的',
              meta: '全部 94 张',
              child: const _PhotoRow(),
            ),
            SizedBox(height: AppSpacing.md(context)),
            ProfileSection(
              key: const Key('profile_section_people'),
              title: '他记得的人',
              meta: '4 个街坊',
              child: _PeopleList(people: people),
            ),
            SizedBox(height: AppSpacing.md(context)),
            ProfileSection(
              key: const Key('profile_section_things'),
              title: '他的家当',
              meta: '6 件',
              child: _ThingsList(things: things),
            ),
            SizedBox(height: AppSpacing.md(context)),
            ProfileSection(
              key: const Key('profile_section_days'),
              title: '更早的日子',
              meta: '10月25日 — 10月29日',
              child: const _DayStrip(),
            ),
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
    return Column(
      children: [
        for (var i = 0; i < people.length; i++)
          _PersonRow(person: people[i], showDivider: i != people.length - 1),
      ],
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
          '${person.role} · ${person.note}',
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
  const _QuoteCard();

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
            '“书不会跑，人会跑。”',
            style: AppTextStyles.body(context).copyWith(
              fontSize: context.sp(14.5),
              height: 1.6,
              color: AppColors.ink,
            ),
          ),
          SizedBox(height: AppSpacing.xs(context)),
          Text(
            '今天 15:32 · 旧书店',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption(
              context,
            ).copyWith(fontSize: context.sp(10.5), color: AppColors.inkFaint),
          ),
        ],
      ),
    );
  }
}

class _ProfileTiles extends StatelessWidget {
  const _ProfileTiles();

  static const _tiles = [
    _TileData('去过的地方', '3', '旧书店 · 旧货市场 · 河堤'),
    _TileData('见过的人', '4', '林叔 · 张姨 · 老赵 · 阿海'),
    _TileData('记着的事', '2', '洗衣机 · 后院的旧书'),
    _TileData('这些天', '5', '从 10月28日 到今天'),
  ];

  @override
  Widget build(BuildContext context) {
    final gap = AppSpacing.sm(context);
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _Tile(data: _tiles[0])),
            SizedBox(width: gap),
            Expanded(child: _Tile(data: _tiles[1])),
          ],
        ),
        SizedBox(height: gap),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _Tile(data: _tiles[2])),
            SizedBox(width: gap),
            Expanded(child: _Tile(data: _tiles[3])),
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
