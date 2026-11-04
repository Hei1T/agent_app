import 'package:flutter/material.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_icon_button.dart';
import '../../../../shared/widgets/app_icon.dart';
import '../../../../shared/widgets/glass_panel.dart';
import '../../../chat/data/demo_chat.dart';
import '../../../chat/domain/entities/chat_message.dart';

class CinemaChatOverlay extends StatefulWidget {
  const CinemaChatOverlay({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  State<CinemaChatOverlay> createState() => _CinemaChatOverlayState();
}

class _CinemaChatOverlayState extends State<CinemaChatOverlay> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  late final List<ChatMessage> _messages = [...demoChat];

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: context.h(0.025),
      top: context.h(0.09),
      bottom: context.h(0.03),
      width: context.h(0.33),
      child: GlassPanel(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            _ChatOverlayHeader(onClose: widget.onClose),
            Expanded(
              child: ListView.separated(
                controller: _scroll,
                padding: EdgeInsets.all(AppSpacing.sm(context)),
                itemCount: _messages.length,
                separatorBuilder: (context, index) =>
                    SizedBox(height: AppSpacing.xs(context)),
                itemBuilder: (context, index) =>
                    _MiniBubble(message: _messages[index]),
              ),
            ),
            _OverlayComposer(controller: _controller, onSend: _send),
          ],
        ),
      ),
    );
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(
        ChatMessage(
          id: 'local-${DateTime.now().millisecondsSinceEpoch}',
          text: text,
          fromCompanion: false,
          read: true,
        ),
      );
      _controller.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
  }
}

class _ChatOverlayHeader extends StatelessWidget {
  const _ChatOverlayHeader({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.sm(context)),
      child: Row(
        children: [
          ClipOval(
            child: SizedBox(
              width: context.r(28),
              height: context.r(28),
              child: Image.asset('assets/media/book1.jpg', fit: BoxFit.cover),
            ),
          ),
          SizedBox(width: AppSpacing.sm(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('笨笨', style: AppTextStyles.bodyStrong(context)),
                Text('旧书店 · 醒着', style: AppTextStyles.micro(context)),
              ],
            ),
          ),
          AppIconButton(
            icon: AppIconName.close,
            onTap: onClose,
            size: context.r(24),
          ),
        ],
      ),
    );
  }
}

class _MiniBubble extends StatelessWidget {
  const _MiniBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.fromCompanion
          ? Alignment.centerLeft
          : Alignment.centerRight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: message.fromCompanion
              ? AppColors.surfaceRaised
              : AppColors.tint,
          borderRadius: BorderRadius.circular(AppRadius.sm(context)),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm(context),
            vertical: AppSpacing.xs(context),
          ),
          child: Text(
            message.text,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption(context).copyWith(
              color: message.fromCompanion ? AppColors.ink : AppColors.ground,
            ),
          ),
        ),
      ),
    );
  }
}

class _OverlayComposer extends StatelessWidget {
  const _OverlayComposer({required this.controller, required this.onSend});

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.sm(context)),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onSubmitted: (_) => onSend(),
              style: AppTextStyles.caption(context),
              decoration: InputDecoration(
                hintText: '跟他说点什么...',
                hintStyle: AppTextStyles.caption(context),
                filled: true,
                fillColor: AppColors.surface,
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.pill(context)),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ),
          SizedBox(width: AppSpacing.xs(context)),
          AppIconButton(
            icon: AppIconName.send,
            onTap: onSend,
            size: context.r(30),
          ),
        ],
      ),
    );
  }
}
