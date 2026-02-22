import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/app/app_routes.dart';
import 'package:echomind_app/providers/question_detail_provider.dart';

class QuestionRelationsWidget extends ConsumerWidget {
  final String questionId;
  const QuestionRelationsWidget({super.key, required this.questionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(questionDetailProvider(questionId));

    final d = detail.whenOrNull(data: (d) => d);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('关联信息', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            _link(context, '归属模型', d?.modelName ?? '电场力分析模型',
                () => context.push(AppRoutes.modelDetailPath(d?.modelId ?? 'mock'))),
            const SizedBox(height: 6),
            _link(context, '关联知识点', d?.knowledgePointName ?? '库仑定律 · 电场强度',
                () => context.push(AppRoutes.knowledgeDetailPath(d?.knowledgePointId ?? 'mock'))),
          ],
        ),
      ),
    );
  }

  Widget _link(BuildContext context, String label, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(children: [
        SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary))),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13, color: AppTheme.primary))),
        const Icon(Icons.chevron_right, size: 16, color: AppTheme.textSecondary),
      ]),
    );
  }
}
