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
  bool? showCancel,
  double heightFactor = 0.55,
  double fullHeightFactor = 0.92,
}) {
  final host = AppSheetHost.hostKey.currentState;
  final body = _AppSheetBody(
    title: title,
    full: full,
    showCancel: showCancel ?? full,
    heightFactor: heightFactor,
    fullHeightFactor: fullHeightFactor,
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
  int _depth = 0;
  bool get _open => _depth > 0;

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

  void _begin() {
    _depth += 1;
    ProviderScope.containerOf(
      context,
    ).read(appSheetOpenProvider.notifier).state = true;
    if (mounted) setState(() {});
  }

  void _end() {
    if (_depth > 0) _depth -= 1;
    if (_depth == 0) {
      ProviderScope.containerOf(
        context,
      ).read(appSheetOpenProvider.notifier).state = false;
    }
    if (mounted) setState(() {});
  }

  Future<void> showRaw(Widget child, {bool dismissible = false}) async {
    final nav = _navigator.currentState;
    if (nav == null) return;
    _begin();
    final route = PageRouteBuilder<void>(
      opaque: false,
      barrierColor: const Color(0x8C000000),
      barrierDismissible: dismissible,
      transitionDuration: const Duration(milliseconds: 180),
      reverseTransitionDuration: const Duration(milliseconds: 160),
      pageBuilder: (context, animation, secondaryAnimation) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).pop(),
              child: const ColoredBox(color: Color(0x8C000000)),
            ),
          ),
          child,
        ],
      ),
    );
    try {
      await nav.push(route);
    } finally {
      _end();
    }
  }

  Future<void> show(Widget sheet) async {
    final nav = _navigator.currentState;
    if (nav == null) return;
    _begin();
    final route = PageRouteBuilder<void>(
      opaque: false,
      barrierColor: const Color(0x85000000),
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 180),
      reverseTransitionDuration: const Duration(milliseconds: 160),
      pageBuilder: (context, animation, secondaryAnimation) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).pop(),
              child: const ColoredBox(color: Color(0x8C000000)),
            ),
          ),
          sheet,
        ],
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
    try {
      await nav.push(route);
    } finally {
      _end();
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

class _AppSheetBody extends StatefulWidget {
  const _AppSheetBody({
    required this.title,
    required this.full,
    required this.showCancel,
    required this.heightFactor,
    required this.fullHeightFactor,
    required this.child,
  });

  final String title;
  final bool full;
  final bool showCancel;
  final double heightFactor;
  final double fullHeightFactor;
  final Widget child;

  @override
  State<_AppSheetBody> createState() => _AppSheetBodyState();
}

class _AppSheetBodyState extends State<_AppSheetBody> {
  double _dragY = 0;

  @override
  Widget build(BuildContext context) {
    final panelWidth = math.min(620.0, context.screenWidth);
    final radius = BorderRadius.vertical(top: Radius.circular(context.r(22)));
    final panelHeight = widget.full
        ? context.screenHeight * widget.fullHeightFactor
        : context.screenHeight * widget.heightFactor;

    final panel = ClipRRect(
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
        child: Column(
          mainAxisSize: widget.full ? MainAxisSize.max : MainAxisSize.min,
          children: [
            _Grabber(onDragUpdate: _onDragUpdate, onDragEnd: _onDragEnd),
            _Header(
              title: widget.title,
              showCancel: widget.showCancel,
              onClose: _close,
              onDragUpdate: _onDragUpdate,
              onDragEnd: _onDragEnd,
            ),
            if (widget.full)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    context.r(14),
                    0,
                    context.r(14),
                    context.r(16),
                  ),
                  child: widget.child,
                ),
              )
            else
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    context.r(14),
                    0,
                    context.r(14),
                    context.r(16),
                  ),
                  child: widget.child,
                ),
              ),
          ],
        ),
      ),
    );

    return Align(
      alignment: Alignment.bottomCenter,
      child: Transform.translate(
        offset: Offset(0, _dragY),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: panelWidth,
            maxHeight: panelHeight,
          ),
          child: widget.full
              ? SizedBox(height: panelHeight, child: panel)
              : panel,
        ),
      ),
    );
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() => _dragY = (_dragY + details.delta.dy).clamp(0.0, 220.0));
  }

  void _onDragEnd(DragEndDetails details) {
    if (_dragY > 90 || details.velocity.pixelsPerSecond.dy > 600) {
      _close();
    } else {
      setState(() => _dragY = 0);
    }
  }

  void _close() {
    Navigator.of(context).pop();
  }
}

class _Grabber extends StatelessWidget {
  const _Grabber({required this.onDragUpdate, required this.onDragEnd});

  final ValueChanged<DragUpdateDetails> onDragUpdate;
  final ValueChanged<DragEndDetails> onDragEnd;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragUpdate: onDragUpdate,
      onVerticalDragEnd: onDragEnd,
      child: SizedBox(
        height: context.r(20),
        child: Center(
          child: Container(
            width: context.r(36),
            height: context.r(4),
            decoration: BoxDecoration(
              color: const Color(0x3BFFFFFF),
              borderRadius: BorderRadius.circular(context.r(2)),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.showCancel,
    required this.onClose,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  final String title;
  final bool showCancel;
  final VoidCallback onClose;
  final ValueChanged<DragUpdateDetails> onDragUpdate;
  final ValueChanged<DragEndDetails> onDragEnd;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragUpdate: onDragUpdate,
      onVerticalDragEnd: onDragEnd,
      child: SizedBox(
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
            if (showCancel)
              Positioned(
                right: context.r(14),
                child: GestureDetector(
                  onTap: onClose,
                  child: Text(
                    '取消',
                    style: AppTextStyles.caption(
                      context,
                    ).copyWith(fontSize: context.sp(8.5)),
                  ),
                ),
              ),
          ],
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
