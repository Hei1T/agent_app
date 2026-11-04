import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/responsive/responsive.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'app_icon.dart';

class MorphDockItem {
  const MorphDockItem({
    required this.label,
    required this.icon,
    this.dot = false,
  });

  final String label;
  final AppIconName icon;
  final bool dot;
}

const _items = [
  MorphDockItem(label: '今天', icon: AppIconName.sun),
  MorphDockItem(label: '朋友圈', icon: AppIconName.moments),
  MorphDockItem(label: '日记', icon: AppIconName.diary),
  MorphDockItem(label: '他', icon: AppIconName.person),
  MorphDockItem(label: '对话', icon: AppIconName.chat, dot: true),
];

/// 同一个 Dock 实例：普通页是五项导航，进入聊天后展开成输入栏。
class MorphDock extends StatefulWidget {
  const MorphDock({
    super.key,
    required this.index,
    required this.chatActive,
    required this.onSelect,
    required this.onChat,
    required this.onSend,
  });

  final int index;
  final bool chatActive;
  final ValueChanged<int> onSelect;
  final VoidCallback onChat;
  final ValueChanged<String> onSend;

  @override
  State<MorphDock> createState() => _MorphDockState();
}

class _MorphDockState extends State<MorphDock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _morph;
  final _input = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _morph = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    if (widget.chatActive) {
      _startForward();
    }
  }

  @override
  void didUpdateWidget(covariant MorphDock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chatActive != widget.chatActive) {
      if (widget.chatActive) {
        _startForward();
      } else {
        _controller.reverse();
        _focus.unfocus();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _input.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _send() {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _input.clear();
    _focus.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final outer = context.r(12);
        final sendWidth = context.r(44);
        final gap = context.r(8);
        final startWidth = context.r(252);
        final endWidth = width - outer * 2 - sendWidth - gap;
        return Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: (_) {
            if (widget.chatActive) _focus.requestFocus();
          },
          child: SizedBox(
            width: width,
            height: context.r(52),
            child: AnimatedBuilder(
              animation: _morph,
              builder: (context, _) {
                final t = _morph.value;
                final barWidth = startWidth + (endWidth - startWidth) * t;
                final barLeft =
                    (width - startWidth) / 2 +
                    (outer - (width - startWidth) / 2) * t;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: barLeft,
                      top: 0,
                      width: barWidth,
                      height: context.r(52),
                      child: _DockShell(
                        t: t,
                        index: widget.index,
                        chatActive: widget.chatActive,
                        onSelect: widget.onSelect,
                        onChat: widget.onChat,
                        input: _input,
                        focus: _focus,
                        onSend: _send,
                      ),
                    ),
                    Positioned(
                      right: outer,
                      top: context.r(4),
                      child: IgnorePointer(
                        ignoring: t < 0.85,
                        child: Opacity(
                          opacity: t,
                          child: Transform.scale(
                            scale: 0.78 + 0.22 * t,
                            child: _SendCircle(onTap: _send),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _DockShell extends StatelessWidget {
  const _DockShell({
    required this.t,
    required this.index,
    required this.chatActive,
    required this.onSelect,
    required this.onChat,
    required this.input,
    required this.focus,
    required this.onSend,
  });

  final double t;
  final int index;
  final bool chatActive;
  final ValueChanged<int> onSelect;
  final VoidCallback onChat;
  final TextEditingController input;
  final FocusNode focus;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(context.r(999));
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
        child: DecoratedBox(
          key: const Key('phone_morph_dock'),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x521B1411), Color(0x300D0A09)],
            ),
            borderRadius: radius,
            border: Border.all(color: const Color(0x2BFFFFFF)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x5C000000),
                blurRadius: 42,
                offset: Offset(0, 20),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: t > 0.15,
                  child: Opacity(
                    opacity: (1 - t * 1.35).clamp(0.0, 1.0).toDouble(),
                    child: _NavRow(
                      index: index,
                      onSelect: onSelect,
                      onChat: onChat,
                    ),
                  ),
                ),
              ),
              IgnorePointer(
                ignoring: !chatActive || t < 0.65,
                child: Opacity(
                  opacity: t,
                  child: _InputRow(input: input, focus: focus, onSend: onSend),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.index,
    required this.onSelect,
    required this.onChat,
  });

  final int index;
  final ValueChanged<int> onSelect;
  final VoidCallback onChat;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < _items.length; i++)
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => i == 4 ? onChat() : onSelect(i),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppIcon(
                        _items[i].icon,
                        size: context.r(18),
                        color: i == index ? AppColors.ink : AppColors.inkFaint,
                      ),
                      SizedBox(height: context.r(2)),
                      Text(
                        _items[i].label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.micro(context).copyWith(
                          fontSize: context.sp(9.5),
                          letterSpacing: 0.02,
                          color: i == index
                              ? AppColors.ink
                              : AppColors.inkFaint,
                        ),
                      ),
                    ],
                  ),
                  if (_items[i].dot)
                    Positioned(
                      top: context.r(7),
                      right: context.r(7),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.green,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF1B1411),
                            width: context.r(2),
                          ),
                        ),
                        child: SizedBox(
                          width: context.r(7),
                          height: context.r(7),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _InputRow extends StatelessWidget {
  const _InputRow({
    required this.input,
    required this.focus,
    required this.onSend,
  });

  final TextEditingController input;
  final FocusNode focus;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.r(14)),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            size: context.r(16),
            color: AppColors.inkFaint,
          ),
          SizedBox(width: context.r(9)),
          Expanded(
            child: TextField(
              controller: input,
              focusNode: focus,
              maxLines: 1,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              style: TextStyle(color: AppColors.ink, fontSize: context.sp(13)),
              decoration: const InputDecoration(
                hintText: '跟他说点什么...',
                hintStyle: TextStyle(color: AppColors.inkFaint),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          SizedBox(width: context.r(9)),
          Icon(
            Icons.camera_alt_outlined,
            size: context.r(18),
            color: AppColors.inkFaint,
          ),
        ],
      ),
    );
  }
}

class _SendCircle extends StatelessWidget {
  const _SendCircle({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: context.r(44),
        height: context.r(44),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xF215100E),
          border: Border.all(color: const Color(0x2BFFFFFF)),
        ),
        child: Icon(
          Icons.arrow_upward_rounded,
          size: context.r(18),
          color: AppColors.ink,
        ),
      ),
    );
  }
}

extension on _MorphDockState {
  void _startForward() {
    _controller.value = 0;
    Future<void>.delayed(const Duration(milliseconds: 140), () {
      if (!mounted || !widget.chatActive) return;
      _controller.forward(from: 0);
    });
  }
}
