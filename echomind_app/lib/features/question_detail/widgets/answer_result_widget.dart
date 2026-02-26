import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/app/app_routes.dart';

class AnswerResultWidget extends StatelessWidget {
  final String questionId;
  const AnswerResultWidget({super.key, required this.questionId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.danger.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('错误', style: TextStyle(fontSize: 12, color: AppTheme.danger, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 8),
              const Text('你的答案: B', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
              const Spacer(),
              const Text('正确答案: ACD', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            ]),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: OutlinedButton(
                onPressed: () => context.push(AppRoutes.aiDiagnosisPath(questionId: questionId)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                ),
                child: const Text('AI 诊断分析', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
