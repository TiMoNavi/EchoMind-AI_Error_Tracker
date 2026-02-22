import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/app/app_routes.dart';
import 'package:echomind_app/providers/exam_provider.dart';

class RecentExamsWidget extends ConsumerWidget {
  const RecentExamsWidget({super.key});

  static const _mockExams = [
    RecentExam(id: 'mock', title: '2025天津模拟卷', date: '2025-01-15', count: '14/20 已录入'),
    RecentExam(id: 'mock', title: '2024全国甲卷', date: '2024-12-20', count: '20/20 已录入'),
    RecentExam(id: 'mock', title: '2024天津期末卷', date: '2024-11-30', count: '8/20 已录入'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final examsAsync = ref.watch(recentExamsProvider);

    final exams = examsAsync.whenOrNull(
      data: (d) => d.isNotEmpty ? d : null,
    ) ?? _mockExams;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('最近卷子', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          for (final e in exams)
            GestureDetector(
              onTap: () => context.push(AppRoutes.uploadHistory),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                child: Row(children: [
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text('${e.date}  ${e.count}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                    ],
                  )),
                  const Icon(Icons.chevron_right, size: 18, color: AppTheme.textSecondary),
                ]),
              ),
            ),
        ],
      ),
    );
  }
}
