import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/app/app_routes.dart';
import 'package:echomind_app/providers/dashboard_provider.dart';

class TopDashboardWidget extends ConsumerWidget {
  const TopDashboardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(dashboardProvider);

    return dashboard.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => _buildContent(context, const DashboardData()),
      data: (data) => _buildContent(context, data),
    );
  }

  Widget _buildContent(BuildContext context, DashboardData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _HeroPredictionCard(
            data: data,
            onTap: () => context.push(AppRoutes.predictionCenter),
          ),
          const SizedBox(height: 16),
          _StatsRow(data: data),
        ],
      ),
    );
  }
}

// ─── Circular Progress Ring Painter ───
class _CircleProgressPainter extends CustomPainter {
  final double progress;
  _CircleProgressPainter({required this.progress});

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
    const gradient = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: 3 * math.pi / 2,
      colors: [Color(0xFFA78BFA), Color(0xFF7C3AED)],
    );
    final progressPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      rect, -math.pi / 2, 2 * math.pi * progress, false, progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircleProgressPainter old) =>
      old.progress != progress;
}

// ─── Trend Painter (violet gradient) ───
class _TrendPainter extends CustomPainter {
  final List<double> data;
  _TrendPainter(List<num> raw)
      : data = raw.map((e) => e.toDouble()).toList();

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;
    final maxV = data.reduce((a, b) => a > b ? a : b);
    final minV = data.reduce((a, b) => a < b ? a : b);
    final range = maxV - minV == 0 ? 1.0 : maxV - minV;

    final points = <Offset>[];
    for (var i = 0; i < data.length; i++) {
      final x = i / (data.length - 1) * size.width;
      final y = size.height -
          ((data[i] - minV) / range) * size.height * 0.85;
      points.add(Offset(x, y));
    }

    // Gradient fill
    final fillPath = Path()..moveTo(0, size.height);
    for (final p in points) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    const accentColor = AppTheme.accent;
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        accentColor.withValues(alpha: 0.2),
        accentColor.withValues(alpha: 0.0),
      ],
    );
    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = gradient.createShader(
          Rect.fromLTWH(0, 0, size.width, size.height),
        ),
    );

    // Line
    final linePaint = Paint()
      ..color = accentColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final linePath = Path()
      ..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(linePath, linePaint);

    // End dot
    canvas.drawCircle(
        points.last, 4, Paint()..color = accentColor);
    canvas.drawCircle(
        points.last, 2.5, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) =>
      false;
}

// ─── Stats Row (uses real data from provider) ───
class _StatsRow extends StatelessWidget {
  final DashboardData data;
  const _StatsRow({required this.data});

  @override
  Widget build(BuildContext context) {
    final stats = [
      ('${data.totalQuestions}', '总题数', const Color(0xFF7C3AED)),
      ('${data.errorCount}', '错题数', const Color(0xFF0EA5E9)),
      ('${data.masteryCount}', '已掌握', const Color(0xFF10B981)),
    ];
    return Row(
      children: [
        for (var i = 0; i < stats.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          Expanded(
            child: _StatOrb(
              value: stats[i].$1,
              label: stats[i].$2,
              accentColor: stats[i].$3,
            ),
          ),
        ],
      ],
    );
  }
}

class _StatOrb extends StatelessWidget {
  final String value;
  final String label;
  final Color accentColor;
  const _StatOrb({
    required this.value,
    required this.label,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        boxShadow: AppTheme.shadowClayStatOrb,
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTheme.heading(size: 26, weight: FontWeight.w900)
                .copyWith(
              color: accentColor,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTheme.label(size: 10, color: AppTheme.muted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Container(
            height: 3,
            width: 32,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Hero Prediction Card (glassmorphism + animated ring) ───
class _HeroPredictionCard extends StatefulWidget {
  final DashboardData data;
  final VoidCallback onTap;
  const _HeroPredictionCard({required this.data, required this.onTap});

  @override
  State<_HeroPredictionCard> createState() => _HeroPredictionCardState();
}

class _HeroPredictionCardState extends State<_HeroPredictionCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fadeAnim;

  double get _targetProgress {
    final score = widget.data.predictedScore ?? 0;
    return (score / 100).clamp(0.0, 1.0);
  }

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.3, 1.0)),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final score = widget.data.predictedScore?.round() ?? 0;
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: double.infinity,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusHero),
          boxShadow: AppTheme.shadowClayCard,
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(decoration: const BoxDecoration(gradient: AppTheme.gradientHero)),
            ),
            Positioned(
              top: -30, right: -20,
              child: Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.accentLight.withValues(alpha: 0.15),
                ),
              ),
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(color: Colors.white.withValues(alpha: 0.1)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                children: [
                  Text('预测分数', style: AppTheme.label(size: 12, color: AppTheme.muted)),
                  const SizedBox(height: 12),
                  _buildMainRow(score),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainRow(int score) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedBuilder(
          animation: _ctrl,
          builder: (context, child) {
            final progress = _targetProgress * _ctrl.value;
            final animScore = (score * _ctrl.value).round();
            return Column(
              children: [
                SizedBox(
                  width: 110, height: 110,
                  child: CustomPaint(
                    painter: _CircleProgressPainter(progress: progress),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$animScore',
                            style: AppTheme.heading(size: 36, weight: FontWeight.w900)
                                .copyWith(color: AppTheme.accent),
                          ),
                          Text('/ 100', style: AppTheme.body(size: 12, color: AppTheme.muted)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text('目标 70 分', style: AppTheme.label(size: 12, color: AppTheme.accent)),
              ],
            );
          },
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: _buildTrendSection(),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('近期趋势', style: AppTheme.label(size: 11, color: AppTheme.muted)),
        const SizedBox(height: 8),
        SizedBox(
          height: 60,
          child: CustomPaint(
            size: const Size(double.infinity, 60),
            painter: _TrendPainter([55, 57, 59, 61, 60, 63]),
          ),
        ),
        const SizedBox(height: 6),
        Row(children: [
          const Icon(Icons.trending_up_rounded, size: 14, color: AppTheme.success),
          const SizedBox(width: 4),
          Text('+3 分 (近7天)', style: AppTheme.label(size: 11, color: AppTheme.success)),
        ]),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('点击查看详情', style: AppTheme.label(size: 12, color: AppTheme.accent)),
            const SizedBox(width: 2),
            const Icon(Icons.chevron_right_rounded, size: 16, color: AppTheme.accent),
          ],
        ),
      ],
    );
  }
}