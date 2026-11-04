import 'package:flutter/material.dart';

import '../../../core/responsive/responsive.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_icon_button.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/app_sheet.dart';
import '../../../shared/widgets/fade_mask.dart';
import '../../../shared/widgets/phone_page.dart';
import '../../../shared/widgets/screen_header.dart';
import '../data/demo_profile.dart';
import '../domain/entities/profile_data.dart';
import 'widgets/profile_hero.dart';
import 'widgets/profile_section.dart';

class ProfileView extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
            ProfileSection(title: '最近拍下的', meta: '全部 94 张', child: _PhotoRow()),
            SizedBox(height: AppSpacing.md(context)),
            ProfileSection(
              title: '他记得的人',
              meta: '4 个街坊',
              child: _PeopleList(people: demoProfile.people),
            ),
            SizedBox(height: AppSpacing.md(context)),
            ProfileSection(
              title: '他的家当',
              meta: '6 件',
              child: _ThingsList(things: demoProfile.things),
            ),
            SizedBox(height: AppSpacing.md(context)),
            ProfileSection(
              title: '更早的日子',
              meta: '10月25日 — 10月29日',
              child: _DayStrip(),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.r(64),
      child: Row(
        children: [
          for (var i = 0; i < 4; i++) ...[
            if (i > 0) SizedBox(width: AppSpacing.xs(context)),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md(context)),
                child: Image.asset(
                  [
                    'assets/media/book1.jpg',
                    'assets/media/book2.jpg',
                    'assets/media/book3.jpg',
                    'assets/media/book1.jpg',
                  ][i],
                  fit: BoxFit.cover,
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
        for (final person in people)
          Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm(context)),
            child: Row(
              children: [
                ClipOval(
                  child: SizedBox(
                    width: context.r(34),
                    height: context.r(34),
                    child: Image.asset(person.photo, fit: BoxFit.cover),
                  ),
                ),
                SizedBox(width: AppSpacing.sm(context)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        person.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        '${person.role} · ${person.note}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: context.r(16),
                  color: Colors.white38,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ThingsList extends StatelessWidget {
  const _ThingsList({required this.things});

  final List<Thing> things;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final thing in things)
          Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm(context)),
            child: Row(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: context.r(18),
                  color: Colors.white54,
                ),
                SizedBox(width: AppSpacing.sm(context)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        thing.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        thing.detail,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: context.r(16),
                  color: Colors.white38,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg(context)),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('他最近说', style: AppTextStyles.micro(context)),
            SizedBox(height: AppSpacing.xs(context)),
            Text('「书不会跑，人会跑。」', style: AppTextStyles.title(context)),
            SizedBox(height: AppSpacing.xs(context)),
            Text('今天 15:32 · 旧书店', style: AppTextStyles.caption(context)),
          ],
        ),
      ),
    );
  }
}

class _ProfileTiles extends StatelessWidget {
  const _ProfileTiles();

  @override
  Widget build(BuildContext context) {
    const tiles = [
      _TileData('去过的地方', '3', '旧书店 · 旧货市场 · 河堤'),
      _TileData('见过的人', '4', '林叔 · 张姨 · 老赵 · 阿海'),
      _TileData('记着的事', '2', '洗衣机 · 后院的旧书'),
      _TileData('这些天', '5', '从 10月28日 到今天'),
    ];
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _Tile(data: tiles[0])),
            SizedBox(width: AppSpacing.xs(context)),
            Expanded(child: _Tile(data: tiles[1])),
          ],
        ),
        SizedBox(height: AppSpacing.xs(context)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _Tile(data: tiles[2])),
            SizedBox(width: AppSpacing.xs(context)),
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
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md(context)),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.sm(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.micro(context),
            ),
            Text(data.value, style: AppTextStyles.title(context)),
            Text(
              data.detail,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption(
                context,
              ).copyWith(fontSize: context.sp(8.5)),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayStrip extends StatelessWidget {
  const _DayStrip();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.r(58),
      child: Row(
        children: [
          for (var i = 0; i < 5; i++) ...[
            if (i > 0) SizedBox(width: AppSpacing.xs(context)),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.sm(context)),
                child: Image.asset(
                  i.isEven
                      ? 'assets/media/book1.jpg'
                      : 'assets/media/book2.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
