import 'package:flutter/material.dart';

import '../../../core/responsive/responsive.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/app_sheet.dart';
import '../../../shared/models/companion.dart';
import 'widgets/cinema_chat_overlay.dart';
import 'widgets/cinema_header.dart';
import 'widgets/cinema_panels.dart';
import 'widgets/cinema_scene.dart';

class CinemaTabletView extends StatelessWidget {
  const CinemaTabletView({
    super.key,
    required this.activeIndex,
    required this.chatOpen,
    required this.onSelect,
    required this.onChat,
    required this.onCloseChat,
  });

  final int activeIndex;
  final bool chatOpen;
  final ValueChanged<int> onSelect;
  final VoidCallback onChat;
  final VoidCallback onCloseChat;

  @override
  Widget build(BuildContext context) {
    return Stack(
      key: const Key('cinema_tablet'),
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: Image.asset('assets/media/book2.jpg', fit: BoxFit.cover),
        ),
        const Positioned.fill(child: _Scrim()),
        Positioned.fill(child: _Content(activeIndex: activeIndex)),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: CinemaHeader(
            activeIndex: activeIndex == 4 ? 0 : activeIndex,
            onSelect: onSelect,
            onMore: () => _showMore(context),
          ),
        ),
        if (!chatOpen)
          Positioned(
            right: context.h(0.025),
            bottom: context.h(0.04),
            child: _ChatFab(onTap: onChat),
          ),
        if (chatOpen) CinemaChatOverlay(onClose: onCloseChat),
      ],
    );
  }

  void _showMore(BuildContext context) {
    showAppSheet(
      context,
      title: '更多',
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg(context)),
        child: Text('更多', style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.activeIndex});

  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return switch (activeIndex) {
      1 => const CinemaMomentsPanel(),
      2 => const CinemaDiaryPanel(),
      3 => const CinemaProfilePanel(),
      _ => CinemaScene(companion: demoCompanion, dayLabel: '11月2日'),
    };
  }
}

class _Scrim extends StatelessWidget {
  const _Scrim();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.scrimTop,
            AppColors.scrimTop.withValues(alpha: 0.15),
            AppColors.scrimBottom,
          ],
          stops: const [0, 0.45, 1],
        ),
      ),
    );
  }
}

class _ChatFab extends StatelessWidget {
  const _ChatFab({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surfaceGlass,
          border: Border.all(color: AppColors.borderStrong),
        ),
        child: SizedBox(
          width: context.r(50),
          height: context.r(50),
          child: Icon(
            Icons.chat_bubble_outline_rounded,
            size: context.r(22),
            color: AppColors.ink,
          ),
        ),
      ),
    );
  }
}
