import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/app/app_routes.dart';
import 'package:echomind_app/providers/exam_provider.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';

class RecentExamsWidget extends ConsumerWidget {
  const RecentExamsWidget({super.key});

  static const _mockExams = [
    RecentExam(
        id: 'mock',
        title: '2025 天津模拟卷（一）',
        date: '2025-01-15',
        count: '14/20 已录入'),
    RecentExam(
        id: 'mock', title: '2024 全国甲卷', date: '2024-12-20', count: '20/20 已录入'),
    RecentExam(
        id: 'mock', title: '2024 天津期末卷', date: '2024-11-30', count: '8/20 已录入'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final examsAsync = ref.watch(recentExamsProvider);
    final exams = examsAsync.whenOrNull(data: (d) => d.isNotEmpty ? d : null) ??
        _mockExams;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('最近卷子',
              style: AppTheme.heading(size: 18, weight: FontWeight.w900)),
          const SizedBox(height: 12),
          for (var i = 0; i < exams.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _buildExamCard(context, exams[i]),
          ],
        ],
      ),
    );
  }

  Widget _buildExamCard(BuildContext context, RecentExam exam) {
    return ClayCard(
      onTap: () => context.push(AppRoutes.uploadHistory),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppTheme.gradientPrimary,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accent.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(Icons.description_outlined,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exam.title,
                  style: AppTheme.body(size: 15, weight: FontWeight.w800),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text('${exam.date} · ${exam.count}',
                    style: AppTheme.label(size: 12)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, size: 18, color: AppTheme.muted),
        ],
      ),
    );
  }
}
