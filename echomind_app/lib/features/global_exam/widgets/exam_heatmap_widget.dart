import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/app/app_routes.dart';
import 'package:echomind_app/providers/exam_provider.dart';

class ExamHeatmapWidget extends ConsumerWidget {
  const ExamHeatmapWidget({super.key});

  static Color _color(int level) => switch (level) {
    0 => const Color(0xFFFF3B30),
    1 => const Color(0xFFFF9500),
    2 => const Color(0xFFFFCC00),
    3 => const Color(0xFF007AFF),
    4 => const Color(0xFF34C759),
    _ => const Color(0xFF00875A),
  };

  static const _mockQuestions = [
    HeatmapQuestion(num: 1, level: 5), HeatmapQuestion(num: 2, level: 4),
    HeatmapQuestion(num: 3, level: 5), HeatmapQuestion(num: 4, level: 3),
    HeatmapQuestion(num: 5, level: 1), HeatmapQuestion(num: 6, level: 4),
    HeatmapQuestion(num: 7, level: 2), HeatmapQuestion(num: 8, level: 5),
    HeatmapQuestion(num: 9, level: 3), HeatmapQuestion(num: 10, level: 0),
    HeatmapQuestion(num: 11, level: 4), HeatmapQuestion(num: 12, level: 2),
    HeatmapQuestion(num: 13, level: 1), HeatmapQuestion(num: 14, level: 3),
    HeatmapQuestion(num: 15, level: 0), HeatmapQuestion(num: 16, level: 5),
    HeatmapQuestion(num: 17, level: 4), HeatmapQuestion(num: 18, level: 2),
    HeatmapQuestion(num: 19, level: 1), HeatmapQuestion(num: 20, level: 3),
  ];

  static const _legend = [
    (label: '未掌握', level: 0), (label: '薄弱', level: 1),
    (label: '不稳定', level: 2), (label: '一般', level: 3),
    (label: '良好', level: 4), (label: '掌握', level: 5),
  ];

  static const _cols = 5;
  static const _cellSize = 40.0;
  static const _gap = 6.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heatmapAsync = ref.watch(examHeatmapProvider);

    final questions = heatmapAsync.whenOrNull(
      data: (d) => d.isNotEmpty ? d : null,
    ) ?? _mockQuestions;

    return _buildGrid(context, questions);
  }

  Widget _buildGrid(BuildContext context, List<HeatmapQuestion> questions) {
    final rows = (questions.length / _cols).ceil();
    final gridWidth = _cols * _cellSize + (_cols - 1) * _gap;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('题号热力图', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: gridWidth,
                height: rows * _cellSize + (rows - 1) * _gap,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _cols, mainAxisSpacing: _gap, crossAxisSpacing: _gap,
                  ),
                  itemCount: questions.length,
                  itemBuilder: (ctx, i) {
                    final q = questions[i];
                    return GestureDetector(
                      onTap: () => ctx.push(AppRoutes.questionAggregate),
                      child: Container(
                        decoration: BoxDecoration(color: _color(q.level), borderRadius: BorderRadius.circular(6)),
                        alignment: Alignment.center,
                        child: Text('${q.num}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(spacing: 10, runSpacing: 4, children: [
              for (final l in _legend)
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: _color(l.level), borderRadius: BorderRadius.circular(2))),
                  const SizedBox(width: 4),
                  Text(l.label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                ]),
            ]),
          ],
        ),
      ),
    );
  }
}
