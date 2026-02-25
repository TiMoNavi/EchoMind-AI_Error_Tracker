import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';
import 'package:google_fonts/google_fonts.dart';

class WeeklyDashboardWidget extends StatelessWidget {
  final String period;
  final String closures;
  final String studyTime;
  final String scoreChange;

  const WeeklyDashboardWidget({
    super.key,
    this.period = '本周 (2月3日 - 2月9日)',
    this.closures = '12',
    this.studyTime = '2h25m',
    this.scoreChange = '+3',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClayCard(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        child: Column(
          children: [
            Text(period, style: AppTheme.label(size: 13)),
            const SizedBox(height: 14),
            _statsRow(),
          ],
        ),
      ),
    );
  }

  Widget _statsRow() {
    return Row(
      children: [
        _stat(closures, '闭环数', null),
        _stat(studyTime, '学习时长', null),
        _stat(scoreChange, '预测分变化', AppTheme.accent),
      ],
    );
  }

  static Widget _stat(String value, String label, Color? valueColor) {
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