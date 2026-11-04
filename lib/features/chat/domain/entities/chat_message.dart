class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.text,
    required this.fromCompanion,
    this.read = false,
  });

  final String id;
  final String text;
  final bool fromCompanion;
  final bool read;
}
