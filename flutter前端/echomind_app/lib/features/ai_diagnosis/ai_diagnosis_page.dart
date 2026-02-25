import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_background_blobs.dart';
import 'package:echomind_app/shared/models/chat_message.dart';
import 'package:echomind_app/shared/widgets/chat/chat_message_list.dart';
import 'package:echomind_app/shared/widgets/chat/chat_input_bar.dart';
import 'package:echomind_app/features/ai_diagnosis/widgets/top_frame_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/app/app_routes.dart';

class AiDiagnosisPage extends StatefulWidget {
  const AiDiagnosisPage({super.key});

  @override
  State<AiDiagnosisPage> createState() => _AiDiagnosisPageState();
}

class _AiDiagnosisPageState extends State<AiDiagnosisPage> {
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadInitialMessages();
  }

  void _loadInitialMessages() {
    _messages.addAll([
      ChatMessage.rich(
        role: MessageRole.system,
        type: MessageContentType.questionRef,
        metadata: {'title': '第5题 — 等量异种点电荷电场分析'},
      ),
      ChatMessage.text(
        role: MessageRole.ai,
        text: '根据你的作答记录，这道题你选了B，正确答案是ACD。\n\n'
            '主要问题：\n1. 对中垂线上电势分布理解有误\n'
            '2. 电场强度变化趋势判断错误\n\n'
            '关联薄弱点：库仑定律适用条件、电场叠加原理',
      ),
    ]);
  }

  void _onSend(String text) {
    setState(() {
      _messages.add(ChatMessage.text(
        role: MessageRole.user,
        text: text,
      ));
      // TODO: call AI API, for now add mock reply
      _messages.add(ChatMessage.loading());
    });
    // Simulate AI response
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _messages.removeWhere((m) => m.type == MessageContentType.loading);
        _messages.add(ChatMessage.text(
          role: MessageRole.ai,
          text: '这是一个模拟的 AI 回复。实际接入 API 后，这里会显示真实的诊断内容。',
        ));
      });
    });
  }

  void _onCardAction(ChatMessage msg) {
    if (msg.type == MessageContentType.conclusion) {
      context.push(AppRoutes.modelTraining);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      body: SafeArea(
        child: Column(
          children: [
            const TopFrameWidget(),
            Expanded(
              child: Stack(
                children: [
                  const ClayBackgroundBlobs(),
                  ChatMessageList(
                    messages: _messages,
                    onCardAction: _onCardAction,
                  ),
                ],
              ),
            ),
            ChatInputBar(
              hintText: '输入你的问题...',
              onSend: _onSend,
            ),
          ],
        ),
      ),
    );
  }
}
