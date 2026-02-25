import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_background_blobs.dart';
import 'package:echomind_app/features/question_aggregate/widgets/top_frame_widget.dart';
import 'package:echomind_app/features/question_aggregate/widgets/single_question_dashboard_widget.dart';
import 'package:echomind_app/features/question_aggregate/widgets/exam_analysis_widget.dart';
import 'package:echomind_app/features/question_aggregate/widgets/question_history_list_widget.dart';

class QuestionAggregatePage extends StatelessWidget {
  const QuestionAggregatePage({super.key});

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
                    padding: const EdgeInsets.only(bottom: 24),
                    children: const [
                      SingleQuestionDashboardWidget(),
                      SizedBox(height: 20),
                      ExamAnalysisWidget(),
                      SizedBox(height: 24),
                      QuestionHistoryListWidget(),
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
