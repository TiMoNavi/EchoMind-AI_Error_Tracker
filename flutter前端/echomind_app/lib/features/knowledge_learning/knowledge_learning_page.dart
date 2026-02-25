import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_background_blobs.dart';
import 'package:echomind_app/shared/models/chat_message.dart';
import 'package:echomind_app/shared/widgets/chat/chat_message_list.dart';
import 'package:echomind_app/shared/widgets/chat/chat_input_bar.dart';
import 'package:echomind_app/features/knowledge_learning/widgets/top_frame_widget.dart';
import 'package:echomind_app/features/knowledge_learning/widgets/step_stage_nav_widget.dart';
import 'package:echomind_app/features/knowledge_learning/widgets/step1_concept_present_widget.dart';

class KnowledgeLearningPage extends StatefulWidget {
  const KnowledgeLearningPage({super.key});

  @override
  State<KnowledgeLearningPage> createState() =>
      _KnowledgeLearningPageState();
}

class _KnowledgeLearningPageState extends State<KnowledgeLearningPage> {
  int _currentStep = 0;
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadInitialMessages();
  }

  void _loadInitialMessages() {
    _messages.addAll([
      ChatMessage.text(
        role: MessageRole.ai,
        text: '库仑定律和万有引力定律都是平方反比定律。'
            '我来考考你, 这两个公式有什么关键区别?',
      ),
    ]);
  }

  void _onSend(String text) {
    setState(() {
      _messages.add(ChatMessage.text(
        role: MessageRole.user, text: text,
      ));
      _messages.add(ChatMessage.loading());
    });
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _messages.removeWhere(
          (m) => m.type == MessageContentType.loading,
        );
        _messages.add(ChatMessage.text(
          role: MessageRole.ai,
          text: '模拟 AI 回复。接入 API 后显示真实学习内容。',
        ));
      });
    });
  }

  void _onOptionSelected(String option) {
    _onSend(option);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      body: SafeArea(
        child: Column(
          children: [
            const TopFrameWidget(),
            StepStageNavWidget(
              currentStep: _currentStep,
              onStepChanged: (i) => setState(
                () => _currentStep = i,
              ),
            ),
            Step1ConceptPresentWidget(
              stepIndex: _currentStep,
            ),
            Expanded(
              child: Stack(
                children: [
                  const ClayBackgroundBlobs(),
                  ChatMessageList(
                    messages: _messages,
                    onOptionSelected: _onOptionSelected,
                  ),
                ],
              ),
            ),
            ChatInputBar(
              hintText: '输入你的回答...',
              onSend: _onSend,
            ),
          ],
        ),
      ),
    );
  }
}