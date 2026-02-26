import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/providers/weekly_review_provider.dart';

class WeeklyDashboardWidget extends ConsumerWidget {
  const WeeklyDashboardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(weeklyReviewProvider);

    return asyncData.when(
      loading: () => const SizedBox(
          height: 80, child: Center(child: CircularProgressIndicator())),
      error: (_, __) => const SizedBox.shrink(),
      data: (data) => _buildContent(data),
    );
  }

  Widget _buildContent(WeeklyReviewData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 基础统计卡
          _buildStatsCard(data),
          const SizedBox(height: 12),
          // 四维能力卡
          _buildAbilityCard(data),
        ],
      ),
    );
  }

  Widget _buildStatsCard(WeeklyReviewData data) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('学习仪表盘',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(children: [
            _Stat('做题数', '${data.totalQuestions}', AppTheme.primary),
            _Stat('正确', '${data.correctCount}', AppTheme.success),
            _Stat('错题', '${data.errorCount}', AppTheme.danger),
            _Stat('新掌握', '${data.newMastered}', AppTheme.warning),
          ]),
        ],
      ),
    );
  }

  Widget _buildAbilityCard(WeeklyReviewData data) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('四维能力',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          _AbilityBar('公式记忆', data.formulaMemoryRate),
          const SizedBox(height: 8),
          _AbilityBar('模型识别', data.modelIdentifyRate),
          const SizedBox(height: 8),
          _AbilityBar('计算准确', data.executionCorrectRate),
          const SizedBox(height: 8),
          _AbilityBar('审题准确', data.overallCorrectRate),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _Stat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w600, color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}

class _AbilityBar extends StatelessWidget {
  final String label;
  final double rate;
  const _AbilityBar(this.label, this.rate);

  @override
  Widget build(BuildContext context) {
    final pct = (rate * 100).toInt();
    return Row(
      children: [
        SizedBox(
          width: 64,
          child: Text(label,
              style:
                  const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: rate.clamp(0, 1),
              minHeight: 8,
              backgroundColor: AppTheme.divider,
              valueColor: AlwaysStoppedAnimation<Color>(
                rate >= 0.8
                    ? AppTheme.success
                    : rate >= 0.5
                        ? AppTheme.warning
                        : AppTheme.danger,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 36,
          child: Text('$pct%',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
