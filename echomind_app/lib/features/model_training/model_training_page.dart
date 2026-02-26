import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/providers/model_training_provider.dart';
import 'package:echomind_app/features/model_training/widgets/top_frame_widget.dart';
import 'package:echomind_app/features/model_training/widgets/step_stage_nav_widget.dart';
import 'package:echomind_app/features/model_training/widgets/step_info_widget.dart';
import 'package:echomind_app/features/model_training/widgets/training_dialogue_widget.dart';
import 'package:echomind_app/features/model_training/widgets/action_overlay_widget.dart';

class ModelTrainingPage extends ConsumerStatefulWidget {
  final String? modelId;
  final String source;
  final String? questionId;

  const ModelTrainingPage({
    super.key,
    this.modelId,
    this.source = 'self_study',
    this.questionId,
  });

  @override
  ConsumerState<ModelTrainingPage> createState() => _ModelTrainingPageState();
}

class _ModelTrainingPageState extends ConsumerState<ModelTrainingPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _initSession());
  }

  Future<void> _initSession() async {
    final notifier = ref.read(trainingProvider.notifier);
    if (widget.modelId != null) {
      // 从模型详情/诊断结论进入：开始新会话
      await notifier.startSession(
        modelId: widget.modelId!,
        source: widget.source,
        questionId: widget.questionId,
      );
    } else {
      // 从菜单进入：恢复活跃会话
      await notifier.fetchActiveSession();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(trainingProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            TopFrameWidget(modelName: state.modelName),
            Expanded(child: _buildBody(state)),
            if (state.isActive) const ActionOverlayWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(TrainingState state) {
    if (state.isLoading && state.messages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null && !state.hasSession) {
      return _buildError(state.errorMessage!);
    }

    if (!state.hasSession) {
      return _buildEmpty();
    }

    // 有会话：显示步骤导航 + 步骤信息 + 对话区
    return Column(
      children: [
        StepStageNavWidget(
          currentStep: state.currentStep,
          entryStep: state.entryStep,
          stepResults: state.stepResults,
        ),
        StepInfoWidget(
          currentStep: state.currentStep,
          stepStatus: state.stepStatus,
        ),
        const Expanded(child: TrainingDialogueWidget()),
      ],
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.model_training_outlined,
                size: 64, color: AppTheme.textSecondary),
            const SizedBox(height: 16),
            const Text('暂无活跃的训练会话',
                style: TextStyle(fontSize: 16, color: AppTheme.textSecondary)),
            const SizedBox(height: 8),
            const Text('从模型详情页点击「开始训练」进入',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                size: 48, color: AppTheme.danger),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _initSession,
              child: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }
}