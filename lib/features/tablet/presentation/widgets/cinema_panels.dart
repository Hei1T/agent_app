import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/contract/diary.dart';
import '../../../../core/contract/moment.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../diary/presentation/widgets/diary_entry_card.dart';
import '../../../moments/presentation/moments_controller.dart';
import '../../../moments/presentation/widgets/moment_card.dart';
import '../../../profile/data/profile_mapper.dart';
import '../../../profile/domain/entities/profile_data.dart';
import '../../../profile/presentation/widgets/profile_hero.dart';
import '../../../profile/presentation/widgets/profile_section.dart';
import '../../../today/data/companion_state_mapper.dart';

class CinemaMomentsPanel extends ConsumerWidget {
  const CinemaMomentsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(momentsProvider);
    ref.watch(momentsControllerProvider);
    final controller = ref.read(momentsControllerProvider.notifier);
    return _PanelScaffold(
      title: '他的朋友圈',
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _PanelMessage(text: '朋友圈暂时连不上：$error'),
        data: (page) => page.items.isEmpty
            ? const _PanelMessage(text: '还没有动态')
            : _MomentsList(moments: page.items, controller: controller),
      ),
    );
  }
}

class _MomentsList extends StatelessWidget {
  const _MomentsList({required this.moments, required this.controller});

  final List<Moment> moments;
  final MomentsController controller;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: moments.length,
      separatorBuilder: (context, index) =>
          SizedBox(height: AppSpacing.md(context)),
      itemBuilder: (context, index) {
        final item = moments[index];
        return MomentCard(
          moment: item,
          liked: controller.isLiked(item),
          likeCount: controller.likeCount(item),
          comments: controller.commentsFor(item),
          onLike: () => controller.toggleLike(item),
          onTap: () {},
        );
      },
    );
  }
}

class CinemaDiaryPanel extends ConsumerWidget {
  const CinemaDiaryPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(diaryProvider);
    return _PanelScaffold(
      title: '他的日记',
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _PanelMessage(text: '日记暂时连不上：$error'),
        data: (page) => page.items.isEmpty
            ? const _PanelMessage(text: '他还没有写过日记。')
            : _DiaryList(entries: page.items),
      ),
    );
  }
}

class _DiaryList extends StatelessWidget {
  const _DiaryList({required this.entries});

  final List<DiaryEntry> entries;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: entries.length,
      separatorBuilder: (context, index) =>
          SizedBox(height: AppSpacing.md(context)),
      itemBuilder: (context, index) => DiaryEntryCard(entry: entries[index]),
    );
  }
}

class CinemaProfilePanel extends ConsumerWidget {
  const CinemaProfilePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(companionStateProvider);
    return _PanelScaffold(
      title: '他',
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _PanelMessage(text: '暂时连不上他：$error'),
        data: (state) {
          final profile = profileOf(state);
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    ProfileHero(companion: companionOf(state)),
                    SizedBox(height: AppSpacing.md(context)),
                    ProfileSection(title: '最近拍下的', child: const _PhotoRow()),
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
                      meta: '${profile.people.length} 个街坊',
                      child: _People(people: profile.people),
                    ),
                    SizedBox(height: AppSpacing.md(context)),
                    ProfileSection(
                      title: '他的家当',
                      meta: '${profile.things.length} 件',
                      child: _Things(things: profile.things),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
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
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.label(context),
              ),
              SizedBox(height: AppSpacing.md(context)),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

class _PanelMessage extends StatelessWidget {
  const _PanelMessage({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.caption(context),
      ),
    );
  }
}

class _PhotoRow extends StatelessWidget {
  const _PhotoRow();

  @override
  Widget build(BuildContext context) {
    // TODO(app-contract): media 代理接入后换成后端照片。
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

  final List<Person> people;

  @override
  Widget build(BuildContext context) {
    if (people.isEmpty) {
      return Text('还没有记住的人。', style: AppTextStyles.caption(context));
    }
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

  final List<Thing> things;

  @override
  Widget build(BuildContext context) {
    if (things.isEmpty) {
      return Text('还没有记下的家当。', style: AppTextStyles.caption(context));
    }
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
                        thing.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyStrong(context),
                      ),
                      Text(
                        thing.detail,
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
