import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';

class TrendCardWidget extends StatelessWidget {
  final List<double> points;
  final List<String> dateLabels;

  const TrendCardWidget({
    super.key,
    this.points = const [55.0, 57.0, 59.0, 61.0, 60.0, 63.0],
    this.dateLabels = const ['1月20日', '1月27日', '2月3日', '2月10日'],
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
            Text('预测分数趋势', style: AppTheme.heading(size: 18)),
            const SizedBox(height: 14),
            SizedBox(
              height: 120,
              child: CustomPaint(
                size: const Size(double.infinity, 120),
                painter: _TrendPainter(points),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: dateLabels.map((d) => Text(d,
                style: AppTheme.label(size: 10),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  final List<double> _points;
  _TrendPainter(this._points);

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = AppTheme.accent
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()..color = AppTheme.accent;
    final dotHaloPaint = Paint()
      ..color = AppTheme.accent.withValues(alpha: 0.15);

    const minY = 50.0;
    const maxY = 70.0;
    final h = size.height;
    final w = size.width;
    final step = w / (_points.length - 1);

    final path = Path();
    for (var i = 0; i < _points.length; i++) {
      final x = i * step;
      final y = h - ((_points[i] - minY) / (maxY - minY)) * h;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 7, dotHaloPaint);
      canvas.drawCircle(Offset(x, y), 3.5, dotPaint);
    }
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}