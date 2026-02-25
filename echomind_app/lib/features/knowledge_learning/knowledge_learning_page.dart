import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/providers/knowledge_learning_provider.dart';
import 'package:echomind_app/features/knowledge_learning/widgets/top_frame_widget.dart';
import 'package:echomind_app/features/knowledge_learning/widgets/step_stage_nav_widget.dart';
import 'package:echomind_app/features/knowledge_learning/widgets/step1_concept_present_widget.dart';
import 'package:echomind_app/features/knowledge_learning/widgets/learning_dialogue_widget.dart';
import 'package:echomind_app/features/knowledge_learning/widgets/action_overlay_widget.dart';

class KnowledgeLearningPage extends ConsumerStatefulWidget {
  const KnowledgeLearningPage({super.key});

  @override
  ConsumerState<KnowledgeLearningPage> createState() =>
      _KnowledgeLearningPageState();
}

class _KnowledgeLearningPageState
    extends ConsumerState<KnowledgeLearningPage> {
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(knowledgeLearningProvider);

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
        Step1ConceptPresentWidget(stepIndex: _currentStep),
        const Expanded(child: LearningDialogueWidget()),
        const ActionOverlayWidget(),
      ],
    );
  }
}
