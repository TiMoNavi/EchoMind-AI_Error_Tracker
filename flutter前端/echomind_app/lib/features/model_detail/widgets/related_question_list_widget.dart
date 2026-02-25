import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/app/app_routes.dart';

class RelatedQuestionListWidget extends StatelessWidget {
  const RelatedQuestionListWidget({super.key});

  static const _items = [
    (correct: false, exam: '2025天津模拟 第5题', desc: '2月8日 · 错误 · 待诊断'),
    (correct: false, exam: '2024天津真题 大题1', desc: '2月3日 · 错误 · 已诊断: 识别错'),
    (correct: true,  exam: '2024天津真题 第4题', desc: '2月3日 · 正确'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('相关题目', style: AppTheme.heading(size: 18)),
              Text('${_items.length}题', style: AppTheme.label(size: 13)),
            ],
          ),
          const SizedBox(height: 10),
          _listGroup(context),
        ],
      ),
    );
  }

  Widget _listGroup(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < _items.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _buildItem(context, _items[i]),
        ],
      ],
    );
  }

  Widget _buildItem(BuildContext context, dynamic item) {
    final bool correct = item.correct as bool;
    final Color statusColor = correct ? AppTheme.success : AppTheme.danger;
    return ClayCard(
      onTap: () => context.push(AppRoutes.questionDetail),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Icon(
              correct ? Icons.check_rounded : Icons.close_rounded,
              size: 16, color: statusColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.exam as String,
                    style: AppTheme.body(size: 14, weight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(item.desc as String,
                    style: AppTheme.label(size: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}