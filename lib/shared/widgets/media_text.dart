import 'package:flutter/material.dart';

import 'media_attachment.dart';

final _imageMarkdown = RegExp(r'!\[([^\]]*)\]\(([^)]+)\)');

/// 文本 + Markdown 图片/视频附件，聊天和主动消息共用。
class MediaRichText extends StatelessWidget {
  const MediaRichText({
    super.key,
    required this.text,
    required this.style,
    this.maxLines,
    this.maxMediaHeight = 220,
  });

  final String text;
  final TextStyle style;
  final int? maxLines;
  final double maxMediaHeight;

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
            child: MediaAttachmentView(
              source: source,
              maxHeight: maxMediaHeight,
            ),
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
