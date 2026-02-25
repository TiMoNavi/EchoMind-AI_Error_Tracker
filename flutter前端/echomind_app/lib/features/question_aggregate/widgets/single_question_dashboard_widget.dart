import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';
import 'package:google_fonts/google_fonts.dart';

class SingleQuestionDashboardWidget extends StatelessWidget {
  final String totalAttempts;
  final String accuracy;
  final String predictedScore;

  const SingleQuestionDashboardWidget({
    super.key,
    this.totalAttempts = '6',
    this.accuracy = '33%',
    this.predictedScore = '2/3',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClayCard(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Row(
          children: [
            Expanded(child: _Stat(value: totalAttempts, label: '累计做题')),
            Expanded(child: _Stat(value: accuracy, label: '正确率')),
            Expanded(child: _Stat(value: predictedScore, label: '预测得分', valueColor: AppTheme.accent)),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value, label;
  final Color? valueColor;
  const _Stat({required this.value, required this.label, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.nunito(
          fontSize: 28, fontWeight: FontWeight.w900,
          color: valueColor ?? AppTheme.foreground,
        )),
        const SizedBox(height: 4),
        Text(label, style: AppTheme.label(size: 11)),
      ],
    );
  }
}
