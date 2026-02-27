import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/app/app_routes.dart';
import 'package:echomind_app/providers/model_detail_provider.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';

class RelatedQuestionListWidget extends ConsumerWidget {
  final String modelId;

  const RelatedQuestionListWidget({super.key, required this.modelId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(modelDetailProvider(modelId));

    final items = async.when(
      loading: () => _fallbackItems,
      error: (_, __) => _fallbackItems,
      data: (data) {
        final generated = <_QuestionItem>[];

        for (var i = 0; i < data.errorCount && i < 2; i++) {
          generated.add(
            _QuestionItem(
              id: 'demo',
              title: '关联题目 ${i + 1}',
              desc: i == 0 ? '最近训练 · 错误 · 待诊断' : '历史训练 · 错误 · 已诊断',
              correct: false,
            ),
          );
        }

        if (data.correctCount > 0) {
          generated.add(
            const _QuestionItem(
              id: 'demo',
              title: '关联题目 · 正确样本',
              desc: '最近训练 · 正确',
              correct: true,
            ),
          );
        }

        return generated.isEmpty ? _fallbackItems : generated;
      },
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('相关题目',
                  style: AppTheme.heading(size: 18, weight: FontWeight.w900)),
              Text('${items.length}题', style: AppTheme.label(size: 13)),
            ],
          ),
          const SizedBox(height: 10),
          Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                _buildItem(context, items[i]),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, _QuestionItem item) {
    final statusColor = item.correct ? AppTheme.success : AppTheme.danger;

    return ClayCard(
      onTap: () => context.push(AppRoutes.questionDetailPath(item.id)),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Icon(
              item.correct ? Icons.check_rounded : Icons.close_rounded,
              size: 16,
              color: statusColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: AppTheme.body(size: 14, weight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(item.desc, style: AppTheme.label(size: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static const _fallbackItems = [
    _QuestionItem(
      id: 'demo',
      title: '2025天津模拟 第5题',
      desc: '2月8日 · 错误 · 待诊断',
      correct: false,
    ),
    _QuestionItem(
      id: 'demo',
      title: '2024天津真题 大题1',
      desc: '2月3日 · 错误 · 已诊断: 识别错',
      correct: false,
    ),
    _QuestionItem(
      id: 'demo',
      title: '2024天津真题 第4题',
      desc: '2月3日 · 正确',
      correct: true,
    ),
  ];
}

class _QuestionItem {
  final String id;
  final String title;
  final String desc;
  final bool correct;

  const _QuestionItem({
    required this.id,
    required this.title,
    required this.desc,
    required this.correct,
  });
}
