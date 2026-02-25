import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class ScoreCardWidget extends StatelessWidget {
  final int score;
  final int totalScore;
  final int targetScore;
  final String gapDescription;

  const ScoreCardWidget({
    super.key,
    this.score = 63,
    this.totalScore = 100,
    this.targetScore = 70,
    this.gapDescription = '差距: 7分 -- 预计 2-3 周可达成',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        decoration: BoxDecoration(
          gradient: AppTheme.gradientHero,
          borderRadius: BorderRadius.circular(AppTheme.radiusHero),
          boxShadow: AppTheme.shadowClayCard,
        ),
        child: Column(
          children: [
            Text('预测分数', style: AppTheme.label(size: 13)),
            const SizedBox(height: 16),
            _progressRing(),
            const SizedBox(height: 16),
            _targetRow(),
            const SizedBox(height: 6),
            Text(gapDescription, style: AppTheme.label(size: 12)),
          ],
        ),
      ),
    );
  }

  Widget _progressRing() {
    final progress = score / totalScore;
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(120, 120),
            painter: _ScoreRingPainter(progress),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score',
                style: GoogleFonts.nunito(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.accent,
                  height: 1.1,
                ),
              ),
              Text(
                '/ $totalScore',
                style: AppTheme.label(size: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _targetRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('目标 ', style: AppTheme.label(size: 13)),
        Text(
          '$targetScore',
          style: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppTheme.accent,
          ),
        ),
        Text(' 分', style: AppTheme.label(size: 13)),
      ],
    );
  }
}

class _ScoreRingPainter extends CustomPainter {
  final double progress;
  _ScoreRingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    const strokeWidth = 10.0;

    final bgPaint = Paint()
      ..color = const Color(0xFFE9E5F5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradientPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
        colors: [Color(0xFFA78BFA), Color(0xFF7C3AED)],
      ).createShader(rect);

    canvas.drawArc(
      rect, -math.pi / 2, 2 * math.pi * progress, false, gradientPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScoreRingPainter old) =>
      old.progress != progress;
}