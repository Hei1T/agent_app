import 'package:flutter/material.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../diary/data/demo_diary.dart';
import '../../../diary/presentation/widgets/diary_entry_card.dart';
import '../../../moments/data/demo_moments.dart';
import '../../../moments/presentation/widgets/moment_card.dart';
import '../../../profile/data/demo_profile.dart';
import '../../../profile/presentation/widgets/profile_hero.dart';
import '../../../profile/presentation/widgets/profile_section.dart';

class CinemaMomentsPanel extends StatefulWidget {
  const CinemaMomentsPanel({super.key});

  @override
  State<CinemaMomentsPanel> createState() => _CinemaMomentsPanelState();
}

class _CinemaMomentsPanelState extends State<CinemaMomentsPanel> {
  final Set<String> _liked = {};

  @override
  Widget build(BuildContext context) {
    return _PanelScaffold(
      title: '他的朋友圈 · 今天',
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: demoMoments.length,
        separatorBuilder: (context, index) =>
            SizedBox(height: AppSpacing.md(context)),
        itemBuilder: (context, index) {
          final item = demoMoments[index];
          return MomentCard(
            moment: item,
            liked: _liked.contains(item.id),
            onLike: () => setState(() {
              if (!_liked.remove(item.id)) _liked.add(item.id);
            }),
            onTap: () {},
          );
        },
      ),
    );
  }
}

class CinemaDiaryPanel extends StatelessWidget {
  const CinemaDiaryPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return _PanelScaffold(
      title: '他的日记',
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: demoDiary.length,
        separatorBuilder: (context, index) =>
            SizedBox(height: AppSpacing.md(context)),
        itemBuilder: (context, index) =>
            DiaryEntryCard(entry: demoDiary[index]),
      ),
    );
  }
}

class CinemaProfilePanel extends StatelessWidget {
  const CinemaProfilePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return _PanelScaffold(
      title: '他',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const ProfileHero(companionName: '笨笨', day: 5),
                SizedBox(height: AppSpacing.md(context)),
                ProfileSection(
                  title: '最近拍下的',
                  meta: '全部 94 张',
                  child: _PhotoRow(),
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.md(context)),
          Expanded(
            flex: 4,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ProfileSection(
                  title: '他记得的人',
                  meta: '4 个街坊',
                  child: _People(people: demoProfile.people),
                ),
                SizedBox(height: AppSpacing.md(context)),
                ProfileSection(
                  title: '他的家当',
                  meta: '6 件',
                  child: _Things(things: demoProfile.things),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PanelScaffold extends StatelessWidget {
  const _PanelScaffold({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xD9080605), Color(0xF2080605)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            context.h(0.05),
            context.h(0.1),
            context.h(0.05),
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.label(context)),
              SizedBox(height: AppSpacing.md(context)),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const photos = [
      'assets/media/book1.jpg',
      'assets/media/book2.jpg',
      'assets/media/book3.jpg',
    ];
    return SizedBox(
      height: context.r(90),
      child: Row(
        children: [
          for (var i = 0; i < photos.length; i++) ...[
            if (i > 0) SizedBox(width: AppSpacing.xs(context)),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md(context)),
                child: Image.asset(photos[i], fit: BoxFit.cover),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _People extends StatelessWidget {
  const _People({required this.people});

  final List<dynamic> people;

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
                    width: context.r(32),
                    height: context.r(32),
                    child: Image.asset(
                      person.photo as String,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.sm(context)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        person.name as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyStrong(context),
                      ),
                      Text(
                        '${person.role} · ${person.note}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Things extends StatelessWidget {
  const _Things({required this.things});

  final List<dynamic> things;

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
                  size: context.r(17),
                  color: AppColors.inkMuted,
                ),
                SizedBox(width: AppSpacing.sm(context)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        thing.name as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyStrong(context),
                      ),
                      Text(
                        thing.detail as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
