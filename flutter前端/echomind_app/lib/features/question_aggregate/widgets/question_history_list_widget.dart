import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/app/app_routes.dart';

class QuestionHistoryListWidget extends StatelessWidget {
  const QuestionHistoryListWidget({super.key});

  static const _items = [
    (correct: false, exam: '2025天津模拟(一) 第5题', desc: '2月8日 · 待诊断'),
    (correct: false, exam: '2024天津模拟(三) 第5题', desc: '2月4日 · 已诊断: 建模层出错'),
    (correct: true,  exam: '2024天津真题 第5题',     desc: '2月3日'),
    (correct: false, exam: '2024天津模拟(一) 第5题', desc: '1月28日 · 已诊断: 执行层出错'),
    (correct: false, exam: '2023天津真题 第5题',     desc: '1月25日 · 已诊断: 建模层出错'),
    (correct: true,  exam: '2023天津模拟(二) 第5题', desc: '1月20日'),
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
              Text('做过的题目', style: AppTheme.heading(size: 18)),
              Text('${_items.length}题', style: AppTheme.label(size: 13)),
            ],
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < _items.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _buildItem(context, _items[i]),
          ],
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, dynamic item) {
    final bool correct = item.correct as bool;
    return ClayCard(
      onTap: () => context.push(AppRoutes.questionDetail),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: correct
                  ? AppTheme.success.withValues(alpha: 0.12)
                  : AppTheme.danger.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                correct ? 'OK' : 'X',
                style: AppTheme.label(
                  size: 13,
                  color: correct ? AppTheme.success : AppTheme.danger,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.exam as String,
                    style: AppTheme.body(size: 14, weight: FontWeight.w600),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text(item.desc as String,
                    style: AppTheme.label(size: 12),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, size: 18, color: AppTheme.muted),
        ],
      ),
    );
  }
}