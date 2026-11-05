import 'package:flutter/material.dart';

import '../../../../shared/widgets/media_attachment.dart';

final _imageMarkdown = RegExp(r'!\[([^\]]*)\]\(([^)]+)\)');

/// 聊天正文：纯文本 + Markdown 图片/视频附件。
/// core 的媒体消息形如 ![image](/media/image/xxx.png)。
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
    final matches = _imageMarkdown.allMatches(text).toList();
    if (matches.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      );
    }
    final children = <Widget>[];
    var cursor = 0;
    for (final match in matches) {
      if (match.start > cursor) {
        final segment = text.substring(cursor, match.start).trim();
        if (segment.isNotEmpty) children.add(Text(segment, style: style));
      }
      final source = match.group(2)!.trim();
      if (source.isNotEmpty) {
        children.add(
          Padding(
            padding: EdgeInsets.symmetric(vertical: children.isEmpty ? 0 : 6),
            child: MediaAttachmentView(source: source, maxHeight: 220),
          ),
        );
      }
      cursor = match.end;
    }
    if (cursor < text.length) {
      final segment = text.substring(cursor).trim();
      if (segment.isNotEmpty) children.add(Text(segment, style: style));
    }
    if (children.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}
