import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:echomind_app/providers/prediction_provider.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';

class ScoreCardWidget extends ConsumerWidget {
  const ScoreCardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prediction = ref.watch(predictionProvider);

    return prediction.when(
      loading: () => const SizedBox(
        height: 140,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => _buildCard(score: 0, target: 90),
      data: (d) => _buildCard(
        score: d.predictedScore.round(),
        target: d.targetScore.round(),
      ),
    );
  }

  Widget _buildCard({required int score, required int target}) {
    final safeTarget = target <= 0 ? 1 : target;
    final progress = (score / safeTarget).clamp(0.0, 1.0);
    final gap = target - score;

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
            SizedBox(
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
                      Text('/ $target', style: AppTheme.label(size: 13)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('目标 ', style: AppTheme.label(size: 13)),
                Text(
                  '$target',
                  style: GoogleFonts.nunito(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.accent,
                  ),
                ),
                Text(' 分', style: AppTheme.label(size: 13)),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              gap > 0 ? '距目标还差 $gap 分，建议优先补弱项。' : '已达到目标分，可冲刺更高分。',
              style: AppTheme.label(size: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreRingPainter extends CustomPainter {
  final double progress;

  const _ScoreRingPainter(this.progress);

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
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      gradientPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScoreRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
