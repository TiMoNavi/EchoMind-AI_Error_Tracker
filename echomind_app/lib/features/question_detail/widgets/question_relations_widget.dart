import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/app/app_routes.dart';
import 'package:echomind_app/providers/question_detail_provider.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';

class QuestionRelationsWidget extends ConsumerWidget {
  final String questionId;

  const QuestionRelationsWidget({super.key, required this.questionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(questionDetailProvider(questionId));
    final d = detail.whenOrNull(data: (v) => v);

    final modelName = _textOr(d?.modelName, '板块运动');
    final modelId = _textOr(d?.modelId, 'demo');

    final knowledgeNames = _knowledgeNames(d?.knowledgePointName);
    final kpId = _textOr(d?.knowledgePointId, 'demo');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClayCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('归属模型', style: AppTheme.label(size: 12)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: [
                _blueTag(
                  context: context,
                  text: modelName,
                  onTap: () => context.push(AppRoutes.modelDetailPath(modelId)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text('关联知识点', style: AppTheme.label(size: 12)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final name in knowledgeNames)
                  _grayTag(
                    context: context,
                    text: name,
                    onTap: () =>
                        context.push(AppRoutes.knowledgeDetailPath(kpId)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _blueTag({
    required BuildContext context,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppTheme.accent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
        child:
            Text(text, style: AppTheme.label(size: 12, color: AppTheme.accent)),
      ),
    );
  }

  Widget _grayTag({
    required BuildContext context,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppTheme.canvas,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
        child: Text(text, style: AppTheme.label(size: 12)),
      ),
    );
  }

  String _textOr(String? raw, String fallback) {
    final text = raw?.trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  List<String> _knowledgeNames(String? raw) {
    final text = raw?.trim() ?? '';
    if (text.isEmpty) {
      return const ['牛顿第二定律', '摩擦力', '动量守恒'];
    }

    final parts = text
        .split(RegExp(r'[，,、/|]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return parts.isEmpty ? [text] : parts;
  }
}
