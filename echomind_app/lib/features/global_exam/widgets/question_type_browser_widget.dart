import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/app/app_routes.dart';
import 'package:echomind_app/providers/exam_provider.dart';

class QuestionTypeBrowserWidget extends ConsumerWidget {
  const QuestionTypeBrowserWidget({super.key});

  static const _mockTypes = [
    QuestionTypeItem(title: '选择题', subtitle: '第1-8题', count: '6/8 掌握', level: 4),
    QuestionTypeItem(title: '实验题', subtitle: '第9-11题', count: '1/3 掌握', level: 2),
    QuestionTypeItem(title: '计算题', subtitle: '第12-14题', count: '0/3 掌握', level: 0),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typesAsync = ref.watch(questionTypesProvider);

    final types = typesAsync.whenOrNull(
      data: (d) => d.isNotEmpty ? d : null,
    ) ?? _mockTypes;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('按题型浏览', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          for (final t in types)
            GestureDetector(
              onTap: () => context.push(AppRoutes.questionAggregate),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                child: Row(children: [
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(t.subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                    ],
                  )),
                  Text(t.count, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, size: 18, color: AppTheme.textSecondary),
                ]),
              ),
            ),
        ],
      ),
    );
  }
}
