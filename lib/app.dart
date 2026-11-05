import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/app_providers.dart';
import 'core/realtime/realtime_bridge.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'shared/widgets/app_sheet.dart';
import 'shared/widgets/proactive_notice.dart';

class BenbenApp extends ConsumerWidget {
  const BenbenApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    ref.listen<AsyncValue<void>>(notificationTapProvider, (previous, next) {
      if (next.hasValue) router.go('/chat');
    });
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: const Color(0xFF0B0908),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: MaterialApp.router(
        routerConfig: router,
        title: '笨笨',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        builder: (context, child) => Stack(
          children: [
            child ?? const SizedBox.shrink(),
            const RealtimeBridge(),
            Positioned.fill(child: AppSheetHost(key: AppSheetHost.hostKey)),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Material(
                type: MaterialType.transparency,
                child: SafeArea(
                  bottom: false,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 462),
                      child: ProactiveNotice(onOpen: () => router.go('/chat')),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
