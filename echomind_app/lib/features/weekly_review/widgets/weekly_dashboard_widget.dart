import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:echomind_app/providers/weekly_review_provider.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';

class WeeklyDashboardWidget extends ConsumerWidget {
  const WeeklyDashboardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(weeklyReviewProvider);

    final data = asyncData.when(
      loading: _DashboardViewData.fallback,
      error: (_, __) => _DashboardViewData.fallback(),
      data: _DashboardViewData.fromApi,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClayCard(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        child: Column(
          children: [
            Text(data.period, style: AppTheme.label(size: 13)),
            const SizedBox(height: 14),
            Row(
              children: [
                _stat(data.closures, '闭环数', null),
                _stat(data.studyTime, '学习时长', null),
                _stat(data.scoreChange, '预测分变化', AppTheme.accent),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String value, String label, Color? valueColor) {
    final color = valueColor ?? AppTheme.foreground;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: AppTheme.canvas,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.nunito(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: AppTheme.label(size: 10)),
            const SizedBox(height: 6),
            Container(
              width: 28,
              height: 3,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardViewData {
  final String period;
  final String closures;
  final String studyTime;
  final String scoreChange;

  const _DashboardViewData({
    required this.period,
    required this.closures,
    required this.studyTime,
    required this.scoreChange,
  });

  factory _DashboardViewData.fromApi(WeeklyReviewData data) {
    final isEmpty = data.totalQuestions == 0 &&
        data.correctCount == 0 &&
        data.errorCount == 0 &&
        data.newMastered == 0 &&
        data.lastWeekScore == 0 &&
        data.thisWeekScore == 0;

    if (isEmpty) return _DashboardViewData.fallback();

    final closures =
        (data.newMastered > 0 ? data.newMastered : data.correctCount)
            .toString();

    final minutes = (data.totalQuestions * 7).clamp(30, 300);
    final hour = (minutes / 60).floor();
    final minute = minutes % 60;
    final time = '${hour}h${minute.toString().padLeft(2, '0')}m';

    final diff = (data.thisWeekScore - data.lastWeekScore).round();
    final score = diff >= 0 ? '+$diff' : '$diff';

    return _DashboardViewData(
      period: '本周学习统计',
      closures: closures,
      studyTime: time,
      scoreChange: score,
    );
  }

  factory _DashboardViewData.fallback() => const _DashboardViewData(
        period: '本周 (2月3日 - 2月9日)',
        closures: '12',
        studyTime: '2h25m',
        scoreChange: '+3',
      );
}
