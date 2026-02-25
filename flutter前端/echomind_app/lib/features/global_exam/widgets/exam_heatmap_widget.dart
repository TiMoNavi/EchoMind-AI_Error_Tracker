import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/app/app_routes.dart';

class ExamHeatmapWidget extends StatelessWidget {
  final List<HeatmapQuestion> questions;

  const ExamHeatmapWidget({
    super.key,
    this.questions = const [
      HeatmapQuestion(num: 5, freq: 18, level: 1),
      HeatmapQuestion(num: 10, freq: 16, level: 0),
      HeatmapQuestion(num: 15, freq: 15, level: 0),
      HeatmapQuestion(num: 7, freq: 12, level: 2),
      HeatmapQuestion(num: 13, freq: 11, level: 1),
      HeatmapQuestion(num: 19, freq: 10, level: 1),
      HeatmapQuestion(num: 4, freq: 9, level: 3),
      HeatmapQuestion(num: 9, freq: 8, level: 3),
      HeatmapQuestion(num: 14, freq: 8, level: 3),
      HeatmapQuestion(num: 18, freq: 7, level: 2),
      HeatmapQuestion(num: 12, freq: 6, level: 2),
      HeatmapQuestion(num: 20, freq: 6, level: 3),
      HeatmapQuestion(num: 2, freq: 5, level: 4),
      HeatmapQuestion(num: 6, freq: 5, level: 4),
      HeatmapQuestion(num: 11, freq: 4, level: 4),
      HeatmapQuestion(num: 17, freq: 4, level: 4),
      HeatmapQuestion(num: 1, freq: 3, level: 5),
      HeatmapQuestion(num: 3, freq: 2, level: 5),
      HeatmapQuestion(num: 8, freq: 2, level: 5),
      HeatmapQuestion(num: 16, freq: 2, level: 5),
    ],
  });

  static const _legend = [
    (label: '未掌握', level: 0),
    (label: '薄弱', level: 1),
    (label: '不稳定', level: 2),
    (label: '一般', level: 3),
    (label: '良好', level: 4),
    (label: '掌握', level: 5),
  ];

  static Color _color(int level) => switch (level) {
    0 => const Color(0xFFFF3B30),
    1 => const Color(0xFFFF9500),
    2 => const Color(0xFFFFCC00),
    3 => const Color(0xFF007AFF),
    4 => const Color(0xFF34C759),
    _ => const Color(0xFF00875A),
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClayCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('题号热力图', style: AppTheme.heading(size: 18)),
            const SizedBox(height: 14),
            LayoutBuilder(builder: (context, constraints) {
              final size = constraints.maxWidth;
              final rects = _layoutTreemap(questions, size, size);
              return SizedBox(
                width: size,
                height: size,
                child: Stack(
                  children: [
                    for (var i = 0; i < rects.length; i++)
                      Positioned(
                        left: rects[i].left,
                        top: rects[i].top,
                        width: rects[i].width,
                        height: rects[i].height,
                        child: GestureDetector(
                          onTap: () => context.push(AppRoutes.questionAggregate),
                          child: Container(
                            margin: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: _color(questions[i].level),
                              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                            ),
                            alignment: Alignment.center,
                            child: _buildLabel(questions[i], rects[i]),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 14),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                for (final l in _legend)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _color(l.level),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(l.label, style: AppTheme.label(size: 11)),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(HeatmapQuestion q, Rect r) {
    final minDim = r.width < r.height ? r.width : r.height;
    if (minDim < 24) return const SizedBox.shrink();
    final fontSize = minDim < 36 ? 10.0 : 13.0;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('${q.num}', style: GoogleFonts.nunito(fontSize: fontSize, fontWeight: FontWeight.w800, color: Colors.white)),
        if (minDim > 40)
          Text('${q.freq}次', style: GoogleFonts.dmSans(fontSize: fontSize - 2, color: Colors.white70)),
      ],
    );
  }

  /// Squarified treemap layout algorithm
  static List<Rect> _layoutTreemap(List<HeatmapQuestion> items, double w, double h) {
    final totalValue = items.fold<double>(0, (s, q) => s + q.freq.toDouble());
    final List<double> areas = items.map<double>((q) => q.freq / totalValue * w * h).toList();
    final rects = List<Rect>.filled(items.length, Rect.zero);
    _squarify(areas, List.generate(items.length, (i) => i), rects, 0, 0, w, h);
    return rects;
  }

  static void _squarify(List<double> areas, List<int> indices, List<Rect> out, double x, double y, double w, double h) {
    if (indices.isEmpty) return;
    if (indices.length == 1) {
      out[indices[0]] = Rect.fromLTWH(x, y, w, h);
      return;
    }

    final total = indices.fold<double>(0, (s, i) => s + areas[i]);
    final bool vertical = w >= h;
    final side = vertical ? h : w;

    double rowSum = 0;
    double bestRatio = double.infinity;
    int split = 0;

    for (var i = 0; i < indices.length; i++) {
      rowSum += areas[indices[i]];
      final rowLen = rowSum / side;
      // worst aspect ratio in this row
      double worst = 0;
      double partSum = 0;
      for (var j = 0; j <= i; j++) {
        partSum += areas[indices[j]];
        final cellSide = areas[indices[j]] / rowLen;
        final ratio = cellSide > rowLen ? cellSide / rowLen : rowLen / cellSide;
        if (ratio > worst) worst = ratio;
      }
      if (worst <= bestRatio) {
        bestRatio = worst;
        split = i + 1;
      } else {
        break;
      }
    }

    // Layout the row
    final rowIndices = indices.sublist(0, split);
    final restIndices = indices.sublist(split);
    final rowTotal = rowIndices.fold<double>(0, (s, i) => s + areas[i]);

    if (vertical) {
      final rowW = rowTotal / h;
      double cy = y;
      for (final idx in rowIndices) {
        final cellH = areas[idx] / rowW;
        out[idx] = Rect.fromLTWH(x, cy, rowW, cellH);
        cy += cellH;
      }
      _squarify(areas, restIndices, out, x + rowW, y, w - rowW, h);
    } else {
      final rowH = rowTotal / w;
      double cx = x;
      for (final idx in rowIndices) {
        final cellW = areas[idx] / rowH;
        out[idx] = Rect.fromLTWH(cx, y, cellW, rowH);
        cx += cellW;
      }
      _squarify(areas, restIndices, out, x, y + rowH, w, h - rowH);
    }
  }
}

class HeatmapQuestion {
  final int num;
  final int freq;
  final int level;

  const HeatmapQuestion({
    required this.num,
    required this.freq,
    required this.level,
  });
}
