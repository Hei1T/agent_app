import 'contract_json.dart';

/// GET /api/v1/chat/history -> 一条玩家可见的对话。
class ChatHistoryMessage {
  const ChatHistoryMessage({
    required this.id,
    required this.role,
    required this.text,
    this.createdAt,
    this.timeLabel,
  });

  final String id;

  /// user | companion
  final String role;
  final String text;
  final String? createdAt;
  final String? timeLabel;

  bool get fromCompanion => role == 'companion';

  factory ChatHistoryMessage.fromJson(Map<String, dynamic> json) =>
      ChatHistoryMessage(
        id: contractId(json['id']) ?? '',
        role: contractStringOr(json['role'], 'user'),
        text: contractStringOr(json['text'], ''),
        createdAt: contractString(json['createdAt']),
        timeLabel: contractString(json['timeLabel']),
      );
}

class ChatHistoryPage {
  const ChatHistoryPage({this.items = const [], this.nextCursor});

  final List<ChatHistoryMessage> items;
  final String? nextCursor;

  factory ChatHistoryPage.fromJson(Map<String, dynamic> json) {
    final raw = json['items'];
    return ChatHistoryPage(
      items: raw is List
          ? [
              for (final item in raw)
                if (item is Map<String, dynamic>)
                  ChatHistoryMessage.fromJson(item),
            ]
          : const [],
      nextCursor: contractString(json['nextCursor']),
    );
  }
}
