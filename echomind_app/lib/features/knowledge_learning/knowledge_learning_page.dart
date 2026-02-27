import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_background_blobs.dart';
import 'package:echomind_app/providers/knowledge_learning_provider.dart';
import 'package:echomind_app/features/knowledge_learning/widgets/step_stage_nav_widget.dart';
import 'package:echomind_app/features/knowledge_learning/widgets/step1_concept_present_widget.dart';

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

class _KnowledgeLearningPageState extends ConsumerState<KnowledgeLearningPage> {
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
    final stepIndex =
        session == null ? 0 : (session.currentStep - 1).clamp(0, 4).toInt();

    ref.listen<KnowledgeLearningState>(knowledgeLearningProvider, (prev, next) {
      if ((prev?.session?.messages.length ?? 0) !=
          (next.session?.messages.length ?? 0)) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.canvas,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(session),
            if (session != null)
              StepStageNavWidget(
                currentStep: stepIndex,
                onStepChanged: (_) {},
              ),
            if (session != null)
              Step1ConceptPresentWidget(stepIndex: stepIndex),
            Expanded(
              child: Stack(
                children: [
                  const ClayBackgroundBlobs(),
                  _buildMessageList(st),
                ],
              ),
            ),
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
            child: Text(
              title,
              style: AppTheme.heading(size: 22, weight: FontWeight.w900),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (session != null && session.status == 'active')
            TextButton(
              onPressed: () async {
                await ref
                    .read(knowledgeLearningProvider.notifier)
                    .completeSession();
              },
              child: Text(
                '结束学习',
                style:
                    AppTheme.label(size: 13, color: AppTheme.danger).copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
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
      return Center(
        child: Text(
          '等待 AI 开场...',
          style: AppTheme.label(size: 13, color: AppTheme.muted).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
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
      child: FractionallySizedBox(
        widthFactor: 0.82,
        alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isAi ? AppTheme.surface : AppTheme.primary,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: isAi ? AppTheme.textPrimary : Colors.white,
            ),
          ),
        ),
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 8),
            Text(
              'AI 思考中...',
              style: AppTheme.label(size: 12, color: AppTheme.muted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar(bool isSending) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          top: BorderSide(
            color: AppTheme.divider.withValues(alpha: 0.7),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputController,
              enabled: !isSending,
              decoration: InputDecoration(
                hintText: '输入你的回答...',
                hintStyle: AppTheme.label(size: 13, color: AppTheme.muted),
                filled: true,
                fillColor: AppTheme.canvas,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
              style: AppTheme.body(size: 14),
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
                color: isSending ? AppTheme.muted : AppTheme.accent,
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
