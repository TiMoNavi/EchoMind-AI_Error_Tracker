import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/providers/question_detail_provider.dart';

class QuestionSourceWidget extends ConsumerWidget {
  final String questionId;
  const QuestionSourceWidget({super.key, required this.questionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(questionDetailProvider(questionId));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: detail.when(
        loading: () => const SizedBox.shrink(),
        error: (_, __) => _buildCard(null, null, null, null),
        data: (d) => _buildCard(d.source, d.questionNumber, d.score, d.attitude),
      ),
    );
  }

  Widget _buildCard(String? source, String? number, String? score, String? attitude) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('来源信息', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          _Row(label: '来源卷子', value: source ?? '2025天津模拟卷'),
          const SizedBox(height: 6),
          _Row(label: '题号', value: number ?? '第5题'),
          const SizedBox(height: 6),
          _Row(label: '分值', value: score ?? '6分'),
          const SizedBox(height: 6),
          _Row(label: '态度', value: attitude ?? '粗心失误'),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label, value;
  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary))),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
    ]);
  }
}
