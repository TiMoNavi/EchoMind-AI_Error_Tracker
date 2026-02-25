/// Roles in a chat conversation.
enum MessageRole { user, ai, system }

/// Content types that can appear in the chat stream.
enum MessageContentType {
  text,
  questionRef,
  conclusion,
  optionChips,
  table,
  stepSummary,
  loading,
}

class ChatMessage {
  final String id;
  final MessageRole role;
  final MessageContentType type;
  final String? text;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.role,
    this.type = MessageContentType.text,
    this.text,
    this.metadata,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Quick factory for a plain text message.
  factory ChatMessage.text({
    required MessageRole role,
    required String text,
  }) {
    return ChatMessage(
      id: _nextId(),
      role: role,
      type: MessageContentType.text,
      text: text,
    );
  }

  /// Factory for AI typing indicator.
  factory ChatMessage.loading() {
    return ChatMessage(
      id: 'loading',
      role: MessageRole.ai,
      type: MessageContentType.loading,
    );
  }

  /// Factory for rich content (cards, tables, chips, etc).
  factory ChatMessage.rich({
    required MessageRole role,
    required MessageContentType type,
    Map<String, dynamic>? metadata,
    String? text,
  }) {
    return ChatMessage(
      id: _nextId(),
      role: role,
      type: type,
      text: text,
      metadata: metadata,
    );
  }

  static int _counter = 0;
  static String _nextId() => 'msg_${++_counter}';
}
