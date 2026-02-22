import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/providers/prediction_provider.dart';

class ScoreCardWidget extends ConsumerWidget {
  const ScoreCardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prediction = ref.watch(predictionProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: prediction.when(
        loading: () => const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())),
        error: (_, __) => _buildCard(72, 85),
        data: (d) => _buildCard(d.predictedScore.round(), d.targetScore.round()),
      ),
    );
  }

  Widget _buildCard(int score, int target) {
    final gap = target - score;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('预测得分', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('$score', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: AppTheme.primary)),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('/ $target', style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
            ),
          ]),
          const SizedBox(height: 8),
          if (gap > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: AppTheme.danger.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
              child: Text('距目标 $target 分还差 $gap 分', style: const TextStyle(fontSize: 12, color: AppTheme.danger)),
            ),
        ],
      ),
    );
  }
}
