import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/responsive/responsive.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/app_icon_button.dart';
import '../../../shared/widgets/phone_page.dart';
import '../../../shared/widgets/screen_header.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/app_sheet.dart';
import '../../../shared/widgets/photo_overlay.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/auth/auth_controller.dart';
import '../domain/entities/chat_message.dart';
import '../data/demo_chat.dart';
import 'chat_outbox.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/chat_composer.dart';

class ChatView extends ConsumerStatefulWidget {
  const ChatView({super.key});

  @override
  ConsumerState<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends ConsumerState<ChatView> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final List<ChatMessage> _messages = [...demoChat];
  bool _sending = false;
  String _streamingText = '';

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pendingPhoto = ref.watch(pendingChatPhotoProvider);
    final pendingNote = ref.watch(pendingChatNoteProvider);
    final landscape = MediaQuery.sizeOf(context).width > 600;
    ref.listen<String?>(chatOutboxProvider, (previous, next) {
      if (next == null) return;
      ref.read(chatOutboxProvider.notifier).state = null;
      _sendMessage(explicitText: next);
    });
    String? lastOutgoingId;
    for (final message in _messages) {
      if (!message.fromCompanion) lastOutgoingId = message.id;
    }
    return PhonePage(
      key: const Key('chat_view'),
      header: ScreenHeader(
        title: '笨笨',
        subtitle: '旧书店 · 有点不舒服 · 醒着',
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIconButton(
              icon: AppIconName.back,
              onTap: () => context.go('/today'),
            ),
            SizedBox(width: AppSpacing.xs(context)),
            ClipOval(
              child: SizedBox(
                width: context.r(30),
                height: context.r(30),
                child: Image.asset('assets/media/book1.jpg', fit: BoxFit.cover),
              ),
            ),
          ],
        ),
        actions: [
          AppIconButton(
            icon: AppIconName.more,
            onTap: () => _showMore(context),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scroll,
              padding: EdgeInsets.fromLTRB(
                AppSpacing.pageH(context),
                context.r(62),
                AppSpacing.pageH(context),
                landscape ? AppSpacing.sm(context) : context.r(104),
              ),
              children: [
                _DayDivider(label: '今天 · 15:02'),
                SizedBox(height: context.r(14)),
                for (var i = 0; i < _messages.length; i++) ...[
                  if (i > 0)
                    SizedBox(
                      height: context.r(
                        _messages[i].fromCompanion ==
                                _messages[i - 1].fromCompanion
                            ? 5
                            : 19,
                      ),
                    ),
                  ChatBubble(
                    message: _messages[i],
                    showAvatar: !_messages[i].fromCompanion
                        ? false
                        : i == 0 || _messages[i - 1].fromCompanion == false,
                    showRead:
                        !_messages[i].fromCompanion &&
                        _messages[i].id == lastOutgoingId,
                  ),
                ],
                if (_streamingText.isNotEmpty) ...[
                  SizedBox(height: AppSpacing.sm(context)),
                  ChatBubble(
                    message: ChatMessage(
                      id: 'streaming',
                      text: _streamingText,
                      fromCompanion: true,
                    ),
                  ),
                ],
                if (pendingPhoto != null) ...[
                  SizedBox(height: AppSpacing.sm(context)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(context.r(16)),
                        child: Image.file(
                          File(pendingPhoto.path),
                          width: context.r(180),
                          height: context.r(180),
                          fit: BoxFit.cover,
                        ),
                      ),
                      if (pendingNote != null) ...[
                        SizedBox(height: context.r(4)),
                        Text(
                          pendingNote,
                          style: AppTextStyles.caption(context),
                        ),
                      ],
                    ],
                  ),
                ],
                SizedBox(height: AppSpacing.sm(context)),
                Row(
                  children: [
                    ClipOval(
                      child: SizedBox(
                        width: context.r(24),
                        height: context.r(24),
                        child: Image.asset(
                          'assets/media/book1.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.xs(context)),
                    Text(
                      '他正在输入...',
                      style: AppTextStyles.caption(context).copyWith(
                        fontSize: context.sp(9),
                        color: AppColors.inkFaint,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (landscape) ChatComposer(controller: _controller, onSend: _send),
        ],
      ),
    );
  }

  void _showMore(BuildContext context) {
    showAppSheet(
      context,
      title: '聊天设置',
      child: SheetActionsWidget(
        actions: const [
          SheetActionData(
            id: 'search',
            label: '查找聊天记录',
            description: '搜他说过的话',
            icon: AppIconName.search,
          ),
          SheetActionData(
            id: 'notice',
            label: '消息通知',
            description: '开着的',
            icon: AppIconName.settings,
          ),
          SheetActionData(
            id: 'clear',
            label: '清空聊天记录',
            description: '只清空这个窗口',
            icon: AppIconName.chat,
            danger: true,
          ),
        ],
        onPick: (id) {
          Navigator.of(context).pop();
          if (id == 'clear') setState(_messages.clear);
        },
      ),
    );
  }

  void _send() {
    _sendMessage();
  }

  Future<void> _sendMessage({String? explicitText}) async {
    final text = (explicitText ?? _controller.text).trim();
    if (text.isEmpty || _sending) return;
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
      _sending = true;
      _streamingText = '';
    });
    ref.read(pendingChatPhotoProvider.notifier).state = null;
    ref.read(pendingChatNoteProvider.notifier).state = null;
    _scrollToEnd();
    var completed = false;
    try {
      await for (final event in ref.read(apiProvider).streamChat(text)) {
        if (!mounted) return;
        if (event.event == 'delta') {
          setState(() => _streamingText += event.data);
          _scrollToEnd();
        } else if (event.event == 'done') {
          completed = true;
          setState(() {
            _messages.add(
              ChatMessage(
                id: 'assistant-${DateTime.now().microsecondsSinceEpoch}',
                text: event.data,
                fromCompanion: true,
                read: true,
              ),
            );
            _streamingText = '';
            _sending = false;
          });
          _scrollToEnd();
        } else if (event.event == 'error') {
          throw ApiException(502, event.data);
        }
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          if (_streamingText.isNotEmpty) {
            _messages.add(
              ChatMessage(
                id: 'partial-${DateTime.now().microsecondsSinceEpoch}',
                text: _streamingText,
                fromCompanion: true,
              ),
            );
          }
          _streamingText = '';
          _sending = false;
        });
        final message =
            error is ApiException && error.code == 'INSUFFICIENT_CREDITS'
            ? '积分不足，这一轮没有开始。'
            : '他那边暂时没接上：$error';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted && !completed) setState(() => _sending = false);
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
      );
    });
  }
}

class _DayDivider extends StatelessWidget {
  const _DayDivider({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(height: 0.5, color: AppColors.divider)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.r(9)),
          child: Text(
            label,
            style: AppTextStyles.caption(
              context,
            ).copyWith(fontSize: context.sp(9.5), color: AppColors.inkFaint),
          ),
        ),
        const Expanded(child: Divider(height: 0.5, color: AppColors.divider)),
      ],
    );
  }
}
