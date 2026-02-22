import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/providers/question_detail_provider.dart';

class QuestionContentWidget extends ConsumerWidget {
  final String questionId;
  const QuestionContentWidget({super.key, required this.questionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(questionDetailProvider(questionId));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: detail.when(
        loading: () => const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())),
        error: (_, __) => _buildCard(null, null),
        data: (d) => _buildCard(d.content, d.options),
      ),
    );
  }

  Widget _buildCard(String? content, String? options) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('题干', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(
            content ?? '如图所示，真空中两个等量异种点电荷+Q和-Q固定在x轴上，关于它们连线的中垂线上各点的电场强度和电势，下列说法正确的是（  ）',
            style: const TextStyle(fontSize: 14, height: 1.6),
          ),
          if (options != null) ...[
            const SizedBox(height: 8),
            Text(options, style: const TextStyle(fontSize: 14, height: 1.6)),
          ],
        ],
      ),
    );
  }
}
