import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';
import 'package:google_fonts/google_fonts.dart';

class ScoreChangeWidget extends StatelessWidget {
  final String previousScore;
  final String currentScore;
  final String previousLabel;
  final String currentLabel;

  const ScoreChangeWidget({
    super.key,
    this.previousScore = '60',
    this.currentScore = '63',
    this.previousLabel = '上周',
    this.currentLabel = '本周',
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
            Text('分数变化', style: AppTheme.heading(size: 18)),
            const SizedBox(height: 16),
            _scoreComparison(),
          ],
        ),
      ),
    );
  }

  Widget _scoreComparison() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _scoreBlock(previousLabel, previousScore, null),
        const SizedBox(width: 16),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: AppTheme.gradientPrimary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 16),
        _scoreBlock(currentLabel, currentScore, AppTheme.accent),
      ],
    );
  }

  static Widget _scoreBlock(String label, String value, Color? color) {
    return Column(
      children: [
        Text(label, style: AppTheme.label(size: 13)),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.nunito(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: color ?? AppTheme.foreground,
          ),
        ),
      ],
    );
  }
}