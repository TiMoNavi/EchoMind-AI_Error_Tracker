import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:echomind_app/providers/question_aggregate_provider.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';

class SingleQuestionDashboardWidget extends ConsumerWidget {
  const SingleQuestionDashboardWidget({super.key});

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
        final attempts = '${data.attemptCount}';
        final accuracy = '${(data.correctRate * 100).round()}%';
        final predicted =
            data.predictedScore <= 0 ? '--' : '${data.predictedScore}';

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ClayCard(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Row(
              children: [
                Expanded(child: _buildStat(value: attempts, label: '累计做题')),
                Expanded(child: _buildStat(value: accuracy, label: '正确率')),
                Expanded(
                  child: _buildStat(
                    value: predicted,
                    label: '预测得分',
                    valueColor: AppTheme.accent,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStat({
    required String value,
    required String label,
    Color? valueColor,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.nunito(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: valueColor ?? AppTheme.foreground,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTheme.label(size: 12).copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
