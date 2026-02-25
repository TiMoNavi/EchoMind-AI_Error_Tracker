import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/app/app_routes.dart';

class RecentExamsWidget extends StatelessWidget {
  final List<RecentExam> exams;

  const RecentExamsWidget({
    super.key,
    this.exams = const [
      RecentExam(title: '2025天津模拟卷', date: '2025-01-15', count: '14/20 已录入'),
      RecentExam(title: '2024全国甲卷', date: '2024-12-20', count: '20/20 已录入'),
      RecentExam(title: '2024天津期末卷', date: '2024-11-30', count: '8/20 已录入'),
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('最近卷子', style: AppTheme.heading(size: 18)),
          const SizedBox(height: 12),
          for (var i = 0; i < exams.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _examCard(context, exams[i]),
          ],
        ],
      ),
    );
  }

  Widget _examCard(BuildContext context, RecentExam e) {
    return ClayCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      onTap: () => context.push(AppRoutes.uploadHistory),
      child: Row(
        children: [
          // Paper icon orb
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
            child: const Icon(
              Icons.description_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.title,
                  style: AppTheme.body(size: 15, weight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '${e.date}  ${e.count}',
                  style: AppTheme.label(size: 12),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            size: 18,
            color: AppTheme.muted,
          ),
        ],
      ),
    );
  }
}

class RecentExam {
  final String title;
  final String date;
  final String count;

  const RecentExam({
    required this.title,
    required this.date,
    required this.count,
  });
}