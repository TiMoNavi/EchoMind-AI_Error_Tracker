import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_background_blobs.dart';
import 'package:echomind_app/features/question_detail/widgets/top_frame_widget.dart';
import 'package:echomind_app/features/question_detail/widgets/question_content_widget.dart';
import 'package:echomind_app/features/question_detail/widgets/answer_result_widget.dart';
import 'package:echomind_app/features/question_detail/widgets/question_relations_widget.dart';
import 'package:echomind_app/features/question_detail/widgets/question_source_widget.dart';

class QuestionDetailPage extends StatelessWidget {
  final String questionId;
  const QuestionDetailPage({super.key, required this.questionId});

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
                    children: [
                      QuestionContentWidget(questionId: questionId),
                      const SizedBox(height: 16),
                      AnswerResultWidget(questionId: questionId),
                      const SizedBox(height: 20),
                      QuestionRelationsWidget(questionId: questionId),
                      const SizedBox(height: 20),
                      QuestionSourceWidget(questionId: questionId),
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
