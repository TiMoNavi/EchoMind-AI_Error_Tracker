import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/app/app_routes.dart';
import 'package:echomind_app/providers/exam_provider.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';

class ExamHeatmapWidget extends ConsumerWidget {
  const ExamHeatmapWidget({super.key});

  static const _fallbackQuestions = [
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
  ];

  static const _legend = [
    (label: '未掌握', level: 0),
    (label: '薄弱', level: 1),
    (label: '不稳定', level: 2),
    (label: '一般', level: 3),
    (label: '良好', level: 4),
    (label: '掌握', level: 5),
  ];

  static Color _levelColor(int level) => switch (level) {
        0 => const Color(0xFFFF3B30),
        1 => const Color(0xFFFF9500),
        2 => const Color(0xFFFFCC00),
        3 => const Color(0xFF007AFF),
        4 => const Color(0xFF34C759),
        _ => const Color(0xFF00875A),
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heatmapAsync = ref.watch(examHeatmapProvider);

    final questions = heatmapAsync.whenOrNull(
          data: (d) => d.isNotEmpty ? _normalize(d) : null,
        ) ??
        _fallbackQuestions;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClayCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('题号热力图',
                style: AppTheme.heading(size: 18, weight: FontWeight.w900)),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
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
                            onTap: () =>
                                context.push(AppRoutes.questionAggregate),
                            child: Container(
                              margin: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: _levelColor(questions[i].level),
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusSm),
                              ),
                              alignment: Alignment.center,
                              child: _buildLabel(questions[i], rects[i]),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
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
                          color: _levelColor(l.level),
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

  List<HeatmapQuestion> _normalize(List<HeatmapQuestion> raw) {
    final normalized = raw
        .map((q) => HeatmapQuestion(
              num: q.num,
              freq: _effectiveFreq(q),
              level: q.level.clamp(0, 5),
            ))
        .toList();

    normalized.sort((a, b) => (b.freq ?? 1).compareTo(a.freq ?? 1));
    return normalized;
  }

  int _effectiveFreq(HeatmapQuestion question) {
    final freq = question.freq ?? 0;
    if (freq > 0) return freq;

    final level = question.level.clamp(0, 5);
    return (7 - level) * 2;
  }

  Widget _buildLabel(HeatmapQuestion question, Rect rect) {
    final minDim = rect.width < rect.height ? rect.width : rect.height;
    if (minDim < 24) return const SizedBox.shrink();

    final fontSize = minDim < 36 ? 10.0 : 13.0;
    final freq = (question.freq ?? 0).clamp(0, 999);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${question.num}',
          style: AppTheme.heading(size: fontSize, weight: FontWeight.w900)
              .copyWith(color: Colors.white),
        ),
        if (minDim > 40)
          Text(
            '$freq次',
            style: AppTheme.label(size: fontSize - 2, color: Colors.white70),
          ),
      ],
    );
  }

  static List<Rect> _layoutTreemap(
      List<HeatmapQuestion> items, double width, double height) {
    if (items.isEmpty || width <= 0 || height <= 0) return const [];

    final totalValue =
        items.fold<double>(0, (sum, q) => sum + (q.freq ?? 1).toDouble());
    if (totalValue <= 0) {
      return List<Rect>.filled(
          items.length, Rect.fromLTWH(0, 0, width, height));
    }

    final areas = items
        .map<double>((q) => (q.freq ?? 1) / totalValue * width * height)
        .toList();
    final rects = List<Rect>.filled(items.length, Rect.zero);

    _squarify(
      areas,
      List<int>.generate(items.length, (i) => i),
      rects,
      0,
      0,
      width,
      height,
    );
    return rects;
  }

  static void _squarify(
    List<double> areas,
    List<int> indices,
    List<Rect> out,
    double x,
    double y,
    double width,
    double height,
  ) {
    if (indices.isEmpty || width <= 0 || height <= 0) return;

    if (indices.length == 1) {
      out[indices[0]] = Rect.fromLTWH(x, y, width, height);
      return;
    }

    final vertical = width >= height;
    final side = vertical ? height : width;
    if (side <= 0) return;

    var rowSum = 0.0;
    var bestRatio = double.infinity;
    var split = 0;

    for (var i = 0; i < indices.length; i++) {
      rowSum += areas[indices[i]];
      final rowLen = rowSum / side;
      if (rowLen <= 0) break;

      var worst = 0.0;
      for (var j = 0; j <= i; j++) {
        final cellSide = areas[indices[j]] / rowLen;
        if (cellSide <= 0) continue;
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

    if (split <= 0) split = 1;

    final rowIndices = indices.sublist(0, split);
    final restIndices = indices.sublist(split);
    final rowTotal = rowIndices.fold<double>(0, (sum, i) => sum + areas[i]);

    if (vertical) {
      final rowWidth = rowTotal / height;
      var currentY = y;
      for (final idx in rowIndices) {
        final cellHeight = rowWidth <= 0 ? 0.0 : areas[idx] / rowWidth;
        out[idx] = Rect.fromLTWH(x, currentY, rowWidth, cellHeight);
        currentY += cellHeight;
      }
      _squarify(
        areas,
        restIndices,
        out,
        x + rowWidth,
        y,
        width - rowWidth,
        height,
      );
    } else {
      final rowHeight = rowTotal / width;
      var currentX = x;
      for (final idx in rowIndices) {
        final cellWidth = rowHeight <= 0 ? 0.0 : areas[idx] / rowHeight;
        out[idx] = Rect.fromLTWH(currentX, y, cellWidth, rowHeight);
        currentX += cellWidth;
      }
      _squarify(
        areas,
        restIndices,
        out,
        x,
        y + rowHeight,
        width,
        height - rowHeight,
      );
    }
  }
}
