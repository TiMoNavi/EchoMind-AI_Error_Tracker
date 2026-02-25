import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_background_blobs.dart';
import 'package:echomind_app/features/model_detail/widgets/top_frame_widget.dart';
import 'package:echomind_app/features/model_detail/widgets/mastery_dashboard_widget.dart';
import 'package:echomind_app/features/model_detail/widgets/prerequisite_knowledge_list_widget.dart';
import 'package:echomind_app/features/model_detail/widgets/related_question_list_widget.dart';
import 'package:echomind_app/features/model_detail/widgets/training_record_list_widget.dart';

class ModelDetailPage extends StatelessWidget {
  const ModelDetailPage({super.key});

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
                  ListView(
                    clipBehavior: Clip.none,
                    padding: const EdgeInsets.only(bottom: 40),
                    children: const [
                      MasteryDashboardWidget(),
                      SizedBox(height: 20),
                      PrerequisiteKnowledgeListWidget(),
                      SizedBox(height: 20),
                      RelatedQuestionListWidget(),
                      SizedBox(height: 20),
                      TrainingRecordListWidget(),
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
