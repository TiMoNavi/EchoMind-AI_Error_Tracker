import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_background_blobs.dart';
import 'package:echomind_app/shared/models/chat_message.dart';
import 'package:echomind_app/shared/widgets/chat/chat_message_list.dart';
import 'package:echomind_app/shared/widgets/chat/chat_input_bar.dart';
import 'package:echomind_app/features/model_training/widgets/top_frame_widget.dart';
import 'package:echomind_app/features/model_training/widgets/step_stage_nav_widget.dart';
import 'package:echomind_app/features/model_training/widgets/step1_identification_training_widget.dart';

class ModelTrainingPage extends StatefulWidget {
  const ModelTrainingPage({super.key});

  @override
  State<ModelTrainingPage> createState() => _ModelTrainingPageState();
}

class _ModelTrainingPageState extends State<ModelTrainingPage> {
  int _currentStep = 0;
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadStep2Messages();
  }

  void _loadStep2Messages() {
    _messages.addAll([
      ChatMessage.rich(
        role: MessageRole.system,
        type: MessageContentType.stepSummary,
        metadata: {
          'step': 'Step 1 识别训练',
          'summary': '耗时 1分30秒 · 正确识别板块运动模型',
        },
      ),
      ChatMessage.text(
        role: MessageRole.ai,
        text: '上一步你成功识别了板块运动模型。'
            '现在, 面对板块运动题, 你的第一步分析是什么?',
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
          text: '模拟 AI 回复。接入 API 后显示真实训练内容。',
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
              onStepChanged: (i) => setState(() => _currentStep = i),
            ),
            Step1IdentificationTrainingWidget(
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
              hintText: '输入你的答案...',
              onSend: _onSend,
            ),
          ],
        ),
      ),
    );
  }
}