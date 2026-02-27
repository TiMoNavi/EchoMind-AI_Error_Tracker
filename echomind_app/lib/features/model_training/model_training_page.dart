import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/features/model_training/widgets/action_overlay_widget.dart';
import 'package:echomind_app/features/model_training/widgets/step_info_widget.dart';
import 'package:echomind_app/features/model_training/widgets/step_stage_nav_widget.dart';
import 'package:echomind_app/features/model_training/widgets/top_frame_widget.dart';
import 'package:echomind_app/features/model_training/widgets/training_dialogue_widget.dart';
import 'package:echomind_app/providers/model_training_provider.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_background_blobs.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';

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
    Future.microtask(_initSession);
  }

  Future<void> _initSession() async {
    final notifier = ref.read(trainingProvider.notifier);

    if (widget.modelId != null) {
      await notifier.startSession(
        modelId: widget.modelId!,
        source: widget.source,
        questionId: widget.questionId,
      );
    } else {
      await notifier.fetchActiveSession();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(trainingProvider);

    return Scaffold(
      backgroundColor: AppTheme.canvas,
      body: SafeArea(
        child: Column(
          children: [
            TopFrameWidget(modelName: state.modelName),
            Expanded(
              child: Stack(
                children: [
                  const ClayBackgroundBlobs(),
                  Positioned.fill(child: _buildBody(state)),
                ],
              ),
            ),
            if (state.isActive) const ActionOverlayWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(TrainingState state) {
    if (state.isLoading && state.messages.isEmpty) {
      return Center(
        child: ClayCard(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2.2),
              ),
              const SizedBox(width: 10),
              Text('正在初始化训练会话...',
                  style: AppTheme.body(size: 14, weight: FontWeight.w700)),
            ],
          ),
        ),
      );
    }

    if (state.errorMessage != null && !state.hasSession) {
      return _buildError(state.errorMessage!);
    }

    if (!state.hasSession) {
      return _buildEmpty();
    }

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
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ClayCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.model_training_outlined,
                  size: 52, color: AppTheme.muted),
              const SizedBox(height: 12),
              Text('暂无可继续的训练会话',
                  style: AppTheme.heading(size: 20, weight: FontWeight.w900)),
              const SizedBox(height: 6),
              Text(
                '请从模型详情页点击“开始模型训练”进入。',
                textAlign: TextAlign.center,
                style: AppTheme.body(
                    size: 14, weight: FontWeight.w600, color: AppTheme.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ClayCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppTheme.danger),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTheme.body(
                    size: 14, weight: FontWeight.w600, color: AppTheme.muted),
              ),
              const SizedBox(height: 14),
              OutlinedButton(
                onPressed: _initSession,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.accent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                ),
                child: Text('重新连接',
                    style: AppTheme.body(size: 14, weight: FontWeight.w800)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
