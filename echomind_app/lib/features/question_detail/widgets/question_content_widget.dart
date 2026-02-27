import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/providers/question_detail_provider.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';

class QuestionContentWidget extends ConsumerWidget {
  final String questionId;

  const QuestionContentWidget({super.key, required this.questionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(questionDetailProvider(questionId));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: detail.when(
        loading: () => _buildCard(
          source: '正在加载题目信息',
          content: '题干内容加载中，请稍候...',
          optionLines: const [],
        ),
        error: (_, __) => _buildCard(
          source: '来源未知',
          content: '暂无题干数据，接口恢复后会自动展示真实内容。',
          optionLines: const [],
        ),
        data: (d) => _buildCard(
          source: _safeText(d.source, fallback: '来源未知'),
          content: _safeText(d.content, fallback: '暂无题干数据，接口恢复后会自动展示真实内容。'),
          optionLines: _optionLines(d.options),
        ),
      ),
    );
  }

  Widget _buildCard({
    required String source,
    required String content,
    required List<String> optionLines,
  }) {
    return ClayCard(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.canvas,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              source,
              style: AppTheme.label(size: 12),
            ),
            const SizedBox(height: 10),
            Text(
              content,
              style: AppTheme.body(size: 15, weight: FontWeight.w600),
            ),
            if (optionLines.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                optionLines.join('\n'),
                style: AppTheme.body(size: 15, weight: FontWeight.w600),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _safeText(String? value, {required String fallback}) {
    final t = value?.trim() ?? '';
    return t.isEmpty ? fallback : t;
  }

  List<String> _optionLines(String? raw) {
    final text = raw?.trim() ?? '';
    if (text.isEmpty) return const [];

    final lines = text
        .split(RegExp(r'[\r\n]+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (lines.length > 1) return lines;

    final chunks = text
        .split(RegExp(r'[；;]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return chunks.length > 1 ? chunks : [text];
  }
}
