import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/providers/prediction_provider.dart';

class TrendCardWidget extends ConsumerWidget {
  const TrendCardWidget({super.key});

  static const _mockPoints = [
    TrendPoint(label: 'W1', value: 58),
    TrendPoint(label: 'W2', value: 62),
    TrendPoint(label: 'W3', value: 60),
    TrendPoint(label: 'W4', value: 65),
    TrendPoint(label: 'W5', value: 68),
    TrendPoint(label: 'W6', value: 72),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prediction = ref.watch(predictionProvider);

    final points = prediction.whenOrNull(
      data: (d) => d.trend.isNotEmpty ? d.trend : null,
    ) ?? _mockPoints;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('预测分趋势', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: CustomPaint(
                size: const Size(double.infinity, 120),
                painter: _TrendPainter(points),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  final List<TrendPoint> points;
  const _TrendPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    final paint = Paint()..color = AppTheme.primary..strokeWidth = 2..style = PaintingStyle.stroke;
    final dotPaint = Paint()..color = AppTheme.primary;

    final values = points.map((p) => p.value).toList();
    final minY = (values.reduce((a, b) => a < b ? a : b) - 10).clamp(0.0, 100.0);
    final maxY = values.reduce((a, b) => a > b ? a : b) + 10;
    final h = size.height - 24;
    final step = size.width / (points.length - 1);

    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final x = i * step;
      final y = h - ((points[i].value - minY) / (maxY - minY)) * h;
      if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
      canvas.drawCircle(Offset(x, y), 3, dotPaint);

      final tp = TextPainter(
        text: TextSpan(text: points[i].label, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, size.height - 14));
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrendPainter old) => old.points != points;
}
