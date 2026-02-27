import 'package:flutter/material.dart';
import 'package:echomind_app/features/model_detail/widgets/mastery_dashboard_widget.dart';
import 'package:echomind_app/features/model_detail/widgets/prerequisite_knowledge_list_widget.dart';
import 'package:echomind_app/features/model_detail/widgets/related_question_list_widget.dart';
import 'package:echomind_app/features/model_detail/widgets/top_frame_widget.dart';
import 'package:echomind_app/features/model_detail/widgets/training_record_list_widget.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_background_blobs.dart';

class ModelDetailPage extends StatelessWidget {
  final String modelId;

  const ModelDetailPage({super.key, required this.modelId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      body: SafeArea(
        child: Column(
          children: [
            TopFrameWidget(modelId: modelId),
            Expanded(
              child: Stack(
                children: [
                  const ClayBackgroundBlobs(),
                  ListView(
                    clipBehavior: Clip.none,
                    padding: const EdgeInsets.only(bottom: 40),
                    children: [
                      MasteryDashboardWidget(modelId: modelId),
                      const SizedBox(height: 20),
                      PrerequisiteKnowledgeListWidget(modelId: modelId),
                      const SizedBox(height: 20),
                      RelatedQuestionListWidget(modelId: modelId),
                      const SizedBox(height: 20),
                      TrainingRecordListWidget(modelId: modelId),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
