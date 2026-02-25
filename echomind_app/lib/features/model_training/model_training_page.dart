import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/providers/model_training_provider.dart';
import 'package:echomind_app/features/model_training/widgets/top_frame_widget.dart';
import 'package:echomind_app/features/model_training/widgets/step_stage_nav_widget.dart';
import 'package:echomind_app/features/model_training/widgets/step1_identification_training_widget.dart';
import 'package:echomind_app/features/model_training/widgets/training_dialogue_widget.dart';
import 'package:echomind_app/features/model_training/widgets/action_overlay_widget.dart';

class ModelTrainingPage extends ConsumerStatefulWidget {
  const ModelTrainingPage({super.key});

  @override
  ConsumerState<ModelTrainingPage> createState() =>
      _ModelTrainingPageState();
}

class _ModelTrainingPageState extends ConsumerState<ModelTrainingPage> {
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(modelTrainingProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: session.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => _buildDemoContent(),
          data: (data) => data == null
              ? _buildDemoContent()
              : _buildDemoContent(),
        ),
      ),
    );
  }

  /// API 未就绪时显示 demo 内容（原硬编码 UI）
  Widget _buildDemoContent() {
    return Column(
      children: [
        const TopFrameWidget(),
        StepStageNavWidget(
          currentStep: _currentStep,
          onStepChanged: (i) => setState(() => _currentStep = i),
        ),
        Step1IdentificationTrainingWidget(stepIndex: _currentStep),
        const Expanded(child: TrainingDialogueWidget()),
        const ActionOverlayWidget(),
      ],
    );
  }
}
