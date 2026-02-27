import 'package:flutter/material.dart';
import 'package:echomind_app/shared/models/chat_message.dart';
import 'package:echomind_app/shared/widgets/chat/chat_bubble.dart';
import 'package:echomind_app/shared/widgets/chat/chat_option_chips.dart';
import 'package:echomind_app/shared/widgets/chat/chat_rich_card.dart';

class ChatMessageList extends StatefulWidget {
  final List<ChatMessage> messages;
  final ValueChanged<String>? onOptionSelected;
  final void Function(ChatMessage message)? onCardAction;

  const ChatMessageList({
    super.key,
    required this.messages,
    this.onOptionSelected,
    this.onCardAction,
  });

  @override
  State<ChatMessageList> createState() => _ChatMessageListState();
}

class _ChatMessageListState extends State<ChatMessageList> {
  final _scrollController = ScrollController();

  @override
  void didUpdateWidget(covariant ChatMessageList old) {
    super.didUpdateWidget(old);
    if (widget.messages.length > old.messages.length) {
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: widget.messages.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _buildMessage(widget.messages[i]),
    );
  }

  Widget _buildMessage(ChatMessage msg) {
    return switch (msg.type) {
      MessageContentType.text => ChatBubble(message: msg),
      MessageContentType.loading => _buildTypingIndicator(),
      MessageContentType.optionChips => ChatOptionChips(
          options: (msg.metadata?['options'] as List?)
              ?.cast<String>() ?? [],
          onSelected: (val) => widget.onOptionSelected?.call(val),
        ),
      _ => ChatRichCard(
          message: msg,
          onAction: () => widget.onCardAction?.call(msg),
        ),
    };
  }

  Widget _buildTypingIndicator() {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 8, height: 8,
              child: CircularProgressIndicator(strokeWidth: 2)),
            SizedBox(width: 8),
            Text('AI 正在思考...',
              style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
          ],
        ),
      ),
    );
  }
}