import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/app/app_routes.dart';
import 'package:echomind_app/providers/question_aggregate_provider.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';

class QuestionHistoryListWidget extends ConsumerWidget {
  const QuestionHistoryListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(questionAggregateProvider);

    return async.when(
      loading: () => const SizedBox(
        height: 80,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (data) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '做过的题目',
                    style: AppTheme.heading(size: 20, weight: FontWeight.w900),
                  ),
                  Text('${data.history.length} 题',
                      style: AppTheme.label(size: 13)),
                ],
              ),
              const SizedBox(height: 12),
              if (data.history.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text('暂无做题记录', style: AppTheme.label(size: 13)),
                  ),
                )
              else
                for (var i = 0; i < data.history.length; i++) ...[
                  if (i > 0) const SizedBox(height: 10),
                  _buildItem(context, data.history[i]),
                ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildItem(BuildContext context, QuestionHistoryItem item) {
    final isCorrect = _isCorrect(item.result);
    final color = isCorrect ? AppTheme.success : AppTheme.danger;
    final mark = isCorrect ? 'OK' : 'X';

    return ClayCard(
      onTap: () =>
          context.push(AppRoutes.questionDetailPath(item.questionId ?? 'demo')),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(mark, style: AppTheme.label(size: 13, color: color)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.exam,
                  style: AppTheme.body(size: 14, weight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '${item.date} · ${item.score}',
                  style: AppTheme.label(size: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, size: 18, color: AppTheme.muted),
        ],
      ),
    );
  }

  bool _isCorrect(String raw) {
    final value = raw.trim().toLowerCase();
    return value.contains('正确') ||
        value.contains('对') ||
        value.contains('correct') ||
        value == '1' ||
        value == 'true';
  }
}
