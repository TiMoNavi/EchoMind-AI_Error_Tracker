import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/providers/prediction_provider.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';

class TrendCardWidget extends ConsumerWidget {
  const TrendCardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prediction = ref.watch(predictionProvider);

    return prediction.when(
      loading: () => const SizedBox(
        height: 150,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => _buildCard(const []),
      data: (d) => _buildCard(d.trend),
    );
  }

  Widget _buildCard(List<TrendPoint> points) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClayCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('预测分走势',
                style: AppTheme.heading(size: 18, weight: FontWeight.w900)),
            const SizedBox(height: 12),
            if (points.isEmpty)
              SizedBox(
                height: 90,
                child: Center(
                  child: Text('数据积累中，上传更多题目后显示趋势。',
                      style: AppTheme.label(size: 12)),
                ),
              )
            else
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

    final values = points.map((p) => p.value).toList();
    final minY =
        (values.reduce((a, b) => a < b ? a : b) - 10).clamp(0.0, 100.0);
    final maxY =
        (values.reduce((a, b) => a > b ? a : b) + 10).clamp(0.0, 120.0);
    final span = (maxY - minY).abs() < 0.001 ? 1.0 : (maxY - minY);

    final chartHeight = size.height - 24;
    final hasOne = points.length == 1;
    final step = hasOne ? 0.0 : size.width / (points.length - 1);

    final linePaint = Paint()
      ..color = AppTheme.accent
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()..color = AppTheme.accent;
    final dotHaloPaint = Paint()
      ..color = AppTheme.accent.withValues(alpha: 0.15);

    final path = Path();

    for (var i = 0; i < points.length; i++) {
      final x = hasOne ? size.width / 2 : i * step;
      final y = chartHeight - ((points[i].value - minY) / span) * chartHeight;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      canvas.drawCircle(Offset(x, y), 7, dotHaloPaint);
      canvas.drawCircle(Offset(x, y), 3.5, dotPaint);

      final textPainter = TextPainter(
        text: TextSpan(text: points[i].label, style: AppTheme.label(size: 10)),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
          canvas, Offset(x - textPainter.width / 2, size.height - 14));
    }

    if (!hasOne) {
      canvas.drawPath(path, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}
