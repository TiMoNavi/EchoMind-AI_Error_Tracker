import 'package:flutter/material.dart';
import 'package:echomind_app/features/global_exam/widgets/exam_heatmap_widget.dart';
import 'package:echomind_app/features/global_exam/widgets/question_type_browser_widget.dart';
import 'package:echomind_app/features/global_exam/widgets/recent_exams_widget.dart';
import 'package:echomind_app/features/global_exam/widgets/top_frame_widget.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_background_blobs.dart';

class GlobalExamPage extends StatelessWidget {
  const GlobalExamPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      body: SafeArea(
        child: Stack(
          children: [
            const ClayBackgroundBlobs(),
            ListView(
              clipBehavior: Clip.none,
              padding: const EdgeInsets.only(bottom: 28),
              children: const [
                TopFrameWidget(),
                SizedBox(height: 4),
                ExamHeatmapWidget(),
                SizedBox(height: 24),
                QuestionTypeBrowserWidget(),
                SizedBox(height: 24),
                RecentExamsWidget(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
