import 'package:flutter/material.dart';

import '../../../../shared/widgets/media_text.dart';

/// 聊天正文：纯文本 + Markdown 图片/视频附件。
class ChatMessageContent extends StatelessWidget {
  const ChatMessageContent({
    super.key,
    required this.text,
    required this.style,
    this.maxLines,
  });

  final String text;
  final TextStyle style;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return MediaRichText(
      text: text,
      style: style,
      maxLines: maxLines,
      maxMediaHeight: 220,
    );
  }
}
