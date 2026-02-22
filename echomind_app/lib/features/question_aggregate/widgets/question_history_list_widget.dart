import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/app/app_routes.dart';

class QuestionHistoryListWidget extends StatelessWidget {
  const QuestionHistoryListWidget({super.key});

  static const _items = [
    (exam: '2025天津模拟卷', date: '2025-01-15', result: '错误', score: '0/6'),
    (exam: '2024全国甲卷', date: '2024-12-20', result: '正确', score: '6/6'),
    (exam: '2024天津期末卷', date: '2024-11-30', result: '错误', score: '2/6'),
    (exam: '2024月考三', date: '2024-10-15', result: '错误', score: '0/6'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('历史记录', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          for (final item in _items)
            GestureDetector(
              onTap: () => context.push(AppRoutes.questionDetailPath('mock')),
              behavior: HitTestBehavior.opaque,
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                child: Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(item.exam, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(item.date, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                    ]),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: item.result == '正确' ? AppTheme.success.withValues(alpha: 0.12) : AppTheme.danger.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(item.result, style: TextStyle(fontSize: 12, color: item.result == '正确' ? AppTheme.success : AppTheme.danger)),
                  ),
                  const SizedBox(width: 8),
                  Text(item.score, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, size: 16, color: AppTheme.textSecondary),
                ]),
              ),
            ),
        ],
      ),
    );
  }
}
