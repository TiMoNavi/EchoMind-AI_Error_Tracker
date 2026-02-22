import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/providers/dashboard_provider.dart';

class LearningStatsWidget extends ConsumerWidget {
  const LearningStatsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(dashboardProvider);

    return dashboard.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => _buildStats([('0', '总题数'), ('0', '错题数'), ('0', '已掌握'), ('0', '薄弱点')]),
      data: (d) => _buildStats([
        ('${d.totalQuestions}', '总题数'),
        ('${d.errorCount}', '错题数'),
        ('${d.masteryCount}', '已掌握'),
        ('${d.weakCount}', '薄弱点'),
      ]),
    );
  }

  Widget _buildStats(List<(String, String)> stats) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('学习统计', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final s in stats)
                  Column(children: [
                    Text(s.$1, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(s.$2, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                  ]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
