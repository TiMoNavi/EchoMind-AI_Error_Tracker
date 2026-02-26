import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/providers/knowledge_learning_provider.dart';
import 'package:echomind_app/features/knowledge_learning/widgets/step_stage_nav_widget.dart';

class KnowledgeLearningPage extends ConsumerStatefulWidget {
  final String knowledgePointId;
  final String source;

  const KnowledgeLearningPage({
    super.key,
    this.knowledgePointId = '',
    this.source = 'self_study',
  });

  @override
  ConsumerState<KnowledgeLearningPage> createState() =>
      _KnowledgeLearningPageState();
}

class _KnowledgeLearningPageState
    extends ConsumerState<KnowledgeLearningPage> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.knowledgePointId.isNotEmpty) {
        ref.read(knowledgeLearningProvider.notifier).startSession(
              widget.knowledgePointId,
              source: widget.source,
            );
      }
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
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

  void _onSend() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    _inputController.clear();
    ref.read(knowledgeLearningProvider.notifier).sendMessage(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(knowledgeLearningProvider);
    final session = st.session;

    // 消息变化时自动滚动
    ref.listen<KnowledgeLearningState>(knowledgeLearningProvider, (prev, next) {
      if ((prev?.session?.messages.length ?? 0) !=
          (next.session?.messages.length ?? 0)) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(session),
            if (session != null)
              StepStageNavWidget(
                currentStep: session.currentStep - 1,
                onStepChanged: (_) {},
              ),
            Expanded(child: _buildMessageList(st)),
            if (session != null && session.status == 'active')
              _buildInputBar(st.isSending),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(LearningSession? session) {
    final title = session != null && session.knowledgePointName.isNotEmpty
        ? '${session.knowledgePointName} · 学习'
        : '知识点学习';
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              ref.read(knowledgeLearningProvider.notifier).reset();
              context.pop();
            },
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          ),
          Expanded(
            child: Text(title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis),
          ),
          if (session != null && session.status == 'active')
            TextButton(
              onPressed: () async {
                await ref
                    .read(knowledgeLearningProvider.notifier)
                    .completeSession();
              },
              child: const Text('结束学习',
                  style: TextStyle(fontSize: 14, color: AppTheme.danger)),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageList(KnowledgeLearningState st) {
    if (st.isLoading && st.session == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (st.error != null && st.session == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(st.error!, style: const TextStyle(color: AppTheme.danger)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                if (widget.knowledgePointId.isNotEmpty) {
                  ref.read(knowledgeLearningProvider.notifier).startSession(
                        widget.knowledgePointId,
                        source: widget.source,
                      );
                }
              },
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    final messages = st.session?.messages ?? [];
    if (messages.isEmpty) {
      return const Center(
        child: Text('等待 AI 开场...', style: TextStyle(color: AppTheme.textSecondary)),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: messages.length + (st.isSending ? 1 : 0),
      itemBuilder: (_, i) {
        if (i == messages.length) {
          return _buildTypingIndicator();
        }
        final msg = messages[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildBubble(msg.content, msg.role == 'assistant'),
        );
      },
    );
  }

  Widget _buildBubble(String text, bool isAi) {
    return Align(
      alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isAi ? AppTheme.surface : AppTheme.primary,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Text(text,
            style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: isAi ? AppTheme.textPrimary : Colors.white)),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16, height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 8),
            Text('AI 思考中...', style: TextStyle(
                fontSize: 14, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar(bool isSending) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.divider, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputController,
              enabled: !isSending,
              decoration: InputDecoration(
                hintText: '输入你的回答...',
                hintStyle: const TextStyle(
                    fontSize: 14, color: AppTheme.textSecondary),
                filled: true,
                fillColor: AppTheme.background,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(fontSize: 14),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _onSend(),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: isSending ? null : _onSend,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSending
                    ? AppTheme.textSecondary
                    : AppTheme.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send, size: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}