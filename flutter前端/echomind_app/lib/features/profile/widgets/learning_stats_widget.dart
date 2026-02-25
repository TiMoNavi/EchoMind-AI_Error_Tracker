import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';
import 'package:google_fonts/google_fonts.dart';

class LearningStatsWidget extends StatelessWidget {
  final List<(String, String)> stats;

  const LearningStatsWidget({
    super.key,
    this.stats = const [
      ('28', '累计天数'),
      ('142', '总闭环数'),
      ('48h', '总学习时长'),
      ('+8', '预测提升'),
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClayCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('学习统计', style: AppTheme.heading(size: 18)),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final s in stats)
                  _statOrb(s.$1, s.$2),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statOrb(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.nunito(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: AppTheme.accent,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTheme.label(size: 11)),
      ],
    );
  }
}
