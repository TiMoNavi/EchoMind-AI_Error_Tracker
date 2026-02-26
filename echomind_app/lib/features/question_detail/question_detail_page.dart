import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
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
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            const TopFrameWidget(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 16),
                children: [
                  QuestionContentWidget(questionId: questionId),
                  const SizedBox(height: 12),
                  AnswerResultWidget(questionId: questionId),
                  const SizedBox(height: 12),
                  QuestionRelationsWidget(questionId: questionId),
                  const SizedBox(height: 12),
                  QuestionSourceWidget(questionId: questionId),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
