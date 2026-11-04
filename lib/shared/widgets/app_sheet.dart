import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/responsive/responsive.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'app_icon.dart';

Future<void> showAppSheet(
  BuildContext context, {
  required String title,
  required Widget child,
  bool full = false,
  double heightFactor = 0.55,
}) {
  final host = AppSheetHost.hostKey.currentState;
  final body = _AppSheetBody(
    title: title,
    full: full,
    heightFactor: heightFactor,
    child: child,
  );
  if (host != null) return host.show(body);
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useSafeArea: false,
    builder: (context) => body,
  );
}

final appSheetOpenProvider = StateProvider<bool>((ref) => false);

Future<void> showPopup(
  BuildContext context,
  Widget child, {
  bool dismissible = true,
}) async {
  final host = AppSheetHost.hostKey.currentState;
  if (host == null) return;
  await host.showRaw(child, dismissible: dismissible);
}

/// Shell 内统一弹层。使用局部 Navigator 让原有的 Navigator.pop 关闭仍然有效。
class AppSheetHost extends StatefulWidget {
  const AppSheetHost({super.key});

  static final GlobalKey<AppSheetHostState> hostKey =
      GlobalKey<AppSheetHostState>();

  @override
  State<AppSheetHost> createState() => AppSheetHostState();
}

class AppSheetHostState extends State<AppSheetHost>
    with WidgetsBindingObserver {
  final _navigator = GlobalKey<NavigatorState>();
  bool _open = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<bool> didPopRoute() async {
    if (_open) {
      _navigator.currentState?.maybePop();
      return true;
    }
    return super.didPopRoute();
  }

  Future<void> showRaw(
    Widget child, {
    bool dismissible = false,
  }) async {
    final nav = _navigator.currentState;
    if (nav == null) return;
    ProviderScope.containerOf(context)
        .read(appSheetOpenProvider.notifier)
        .state = true;
    setState(() => _open = true);
    final route = PageRouteBuilder<void>(
      opaque: false,
      barrierColor: const Color(0x8C000000),
      barrierDismissible: dismissible,
      transitionDuration: const Duration(milliseconds: 180),
      reverseTransitionDuration: const Duration(milliseconds: 160),
      pageBuilder: (context, animation, secondaryAnimation) => child,
    );
    await nav.push(route);
    if (mounted) {
      ProviderScope.containerOf(context)
          .read(appSheetOpenProvider.notifier)
          .state = false;
      setState(() => _open = false);
    }
  }

  Future<void> show(Widget sheet) async {
    final nav = _navigator.currentState;
    if (nav == null) return;
    ProviderScope.containerOf(context)
        .read(appSheetOpenProvider.notifier)
        .state = true;
    setState(() => _open = true);
    final route = PageRouteBuilder<void>(
      opaque: false,
      barrierColor: const Color(0x85000000),
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 180),
      reverseTransitionDuration: const Duration(milliseconds: 160),
      pageBuilder: (context, animation, secondaryAnimation) => ColoredBox(
        color: const Color(0x8C000000),
        child: sheet,
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
    await nav.push(route);
    if (mounted) {
      ProviderScope.containerOf(context)
          .read(appSheetOpenProvider.notifier)
          .state = false;
      setState(() => _open = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: PopScope(
        canPop: !_open,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop && _open) {
            _navigator.currentState?.maybePop();
          }
        },
        child: IgnorePointer(
          ignoring: !_open,
          child: Navigator(
        key: _navigator,
        onGenerateRoute: (_) => PageRouteBuilder<void>(
          opaque: false,
          pageBuilder: (context, animation, secondaryAnimation) =>
              const SizedBox.shrink(),
          ),
          ),
        ),
      ),
    );
  }
}

class _AppSheetBody extends StatelessWidget {
  const _AppSheetBody({
    required this.title,
    required this.full,
    required this.heightFactor,
    required this.child,
  });

  final String title;
  final bool full;
  final double heightFactor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final panelWidth = math.min(620.0, context.screenWidth);
    final radius = BorderRadius.vertical(top: Radius.circular(context.r(22)));
    Widget panel(Widget body) {
      return ClipRRect(
        borderRadius: radius,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1D1613), Color(0xFF0F0B09)],
            ),
            border: Border(top: BorderSide(color: Color(0x1FFFFFFF), width: 0.5)),
          ),
          child: body,
        ),
      );
    }

    final grabber = Container(
      width: context.r(36),
      height: context.r(4),
      decoration: BoxDecoration(
        color: const Color(0x3BFFFFFF),
        borderRadius: BorderRadius.circular(context.r(2)),
      ),
    );

    if (full) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: SizedBox(
          width: panelWidth,
          height: context.screenHeight * 0.92,
          child: panel(
            Column(
              children: [
                SizedBox(height: context.r(16)),
                grabber,
                SizedBox(
                  width: double.infinity,
                  height: context.r(34),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.caption(context).copyWith(
                          fontSize: context.sp(9.5),
                          letterSpacing: 1.6,
                          color: AppColors.inkFaint,
                        ),
                      ),
                      Positioned(
                        right: context.r(14),
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Text(
                            '取消',
                            style: AppTextStyles.caption(context).copyWith(
                              fontSize: context.sp(8.5),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      context.r(14),
                      0,
                      context.r(14),
                      context.r(16),
                    ),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: panelWidth,
          maxHeight: context.screenHeight * heightFactor,
        ),
        child: panel(
          SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: context.r(16)),
                grabber,
                SizedBox(
                  width: double.infinity,
                  height: context.r(34),
                  child: Center(
                    child: Text(
                      title,
                      style: AppTextStyles.caption(context).copyWith(
                        fontSize: context.sp(9.5),
                        letterSpacing: 1.6,
                        color: AppColors.inkFaint,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    context.r(14),
                    0,
                    context.r(14),
                    context.r(16),
                  ),
                  child: child,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SheetActionData {
  const SheetActionData({
    required this.id,
    required this.label,
    this.description,
    this.icon,
    this.danger = false,
  });

  final String id;
  final String label;
  final String? description;
  final AppIconName? icon;
  final bool danger;
}

class SheetActionsWidget extends StatelessWidget {
  const SheetActionsWidget({
    super.key,
    required this.actions,
    required this.onPick,
  });

  final List<SheetActionData> actions;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.sm(context),
        0,
        AppSpacing.sm(context),
        AppSpacing.md(context),
      ),
      itemCount: actions.length,
      separatorBuilder: (context, index) => SizedBox(height: context.r(2)),
      itemBuilder: (context, index) {
        final action = actions[index];
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onPick(action.id),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm(context),
              vertical: AppSpacing.sm(context),
            ),
            child: Row(
              children: [
                if (action.icon != null) ...[
                  AppIcon(
                    action.icon!,
                    size: context.r(18),
                    color: action.danger
                        ? AppColors.danger
                        : AppColors.inkMuted,
                  ),
                  SizedBox(width: AppSpacing.sm(context)),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        action.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyStrong(context).copyWith(
                          color: action.danger
                              ? AppColors.danger
                              : AppColors.ink,
                        ),
                      ),
                      if (action.description != null)
                        Text(
                          action.description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption(context),
                        ),
                    ],
                  ),
                ),
                AppIcon(
                  AppIconName.chevron,
                  size: context.r(14),
                  color: AppColors.inkFaint,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
