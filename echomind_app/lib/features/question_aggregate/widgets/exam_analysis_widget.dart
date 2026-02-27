import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/providers/question_aggregate_provider.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';

class ExamAnalysisWidget extends ConsumerWidget {
  const ExamAnalysisWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(questionAggregateProvider);

    return async.when(
      loading: () => const SizedBox(
        height: 80,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (data) {
        final tendency = _splitTags(data.errorTendency);
        final weakPoints = _splitTags(data.weakPoints);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ClayCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _buildBadgeDanger('错因诊断'),
                    _buildBadgeGray('预测 ${data.predictedScore} 分'),
                  ],
                ),
                const SizedBox(height: 14),
                Text('错误倾向', style: AppTheme.label(size: 12)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final item in tendency) _buildBadgeBlue(item)
                  ],
                ),
                const SizedBox(height: 14),
                Text('关联薄弱点', style: AppTheme.label(size: 12)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final item in weakPoints) _buildBadgeDark(item)
                  ],
                ),
                const SizedBox(height: 14),
                Text('学习建议', style: AppTheme.label(size: 12)),
                const SizedBox(height: 8),
                Text(
                  data.suggestion.trim().isEmpty ? '暂无建议数据。' : data.suggestion,
                  style: AppTheme.body(size: 14, weight: FontWeight.w600),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<String> _splitTags(String raw) {
    if (raw.trim().isEmpty) return const ['暂无数据'];
    final parts = raw
        .split(RegExp(r'[\n，,。；;]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    return parts.isEmpty ? const ['暂无数据'] : parts;
  }

  Widget _buildBadgeDanger(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.danger,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Text(text, style: AppTheme.label(size: 12, color: Colors.white)),
    );
  }

  Widget _buildBadgeGray(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.canvas,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Text(text, style: AppTheme.label(size: 12)),
    );
  }

  Widget _buildBadgeBlue(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child:
          Text(text, style: AppTheme.label(size: 12, color: AppTheme.accent)),
    );
  }

  Widget _buildBadgeDark(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.foreground,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Text(text, style: AppTheme.label(size: 12, color: Colors.white)),
    );
  }
}
