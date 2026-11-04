import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/responsive/responsive.dart';
import '../../../shared/widgets/app_sheet.dart';
import '../../../shared/widgets/dock.dart';

import '../../../shared/widgets/side_dock.dart';
import '../../tablet/presentation/cinema_tablet_view.dart';
import 'widgets/phone_right_panel.dart';

class CompanionShell extends StatelessWidget {
  const CompanionShell({
    super.key,
    required this.location,
    required this.child,
  });

  final String location;
  final Widget child;

  int get _index {
    if (location.startsWith('/moments')) return 1;
    if (location.startsWith('/diary')) return 2;
    if (location.startsWith('/me')) return 3;
    if (location.startsWith('/chat')) return 4;
    return 0;
  }

  void _go(BuildContext context, int index) {
    const paths = ['/today', '/moments', '/diary', '/me', '/chat'];
    context.go(paths[index]);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final tablet = size.shortestSide >= 600;
    final portrait = size.height >= size.width;
    if (tablet) {
      return Scaffold(
        key: const Key('companion_shell_tablet'),
        backgroundColor: Colors.black,
        body: CinemaTabletView(
          activeIndex: _index,
          chatOpen: location.startsWith('/chat'),
          onSelect: (i) => _go(context, i),
          onChat: () => context.go('/chat'),
          onCloseChat: () => context.go('/today'),
        ),
      );
    }

    final chat = location.startsWith('/chat');
    final rightWidth = size.width * 0.37;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      key: const Key('companion_shell_phone'),
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: Image.asset('assets/media/bg.png', fit: BoxFit.cover),
            ),
          ),
          Positioned.fill(
            left: !portrait ? context.r(58) : 0,
            right: !portrait ? rightWidth : 0,
            child: child,
          ),
          if (!portrait)
            Positioned(
              top: 0,
              right: 0,
              bottom: 0,
              width: rightWidth,
              child: const SafeArea(
                top: true,
                bottom: false,
                child: PhoneRightPanel(),
              ),
            ),
          if (!portrait)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: SafeArea(
                child: Center(
                  child: SideDock(
                    index: _index,
                    onSelect: (i) => _go(context, i),
                  ),
                ),
              ),
            ),
          if (!chat && portrait)
            Positioned(
              left: 0,
              right: 0,
              bottom: bottomInset + context.r(12),
              child: Center(
                child: Consumer(
                  builder: (context, ref, child) {
                    final sheetOpen = ref.watch(appSheetOpenProvider);
                    if (sheetOpen) return const SizedBox.shrink();
                    return Dock(
                      index: _index,
                      onSelect: (i) => _go(context, i),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
