import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/app/app_routes.dart';

class RelatedQuestionListWidget extends StatelessWidget {
  const RelatedQuestionListWidget({super.key});

  static const _items = [
    ('第5题', '等量异种点电荷电场分析', '错误'),
    ('第12题', '斜面上物体受力平衡', '正确'),
    ('第8题', '弹簧连接体受力分析', '错误'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('关联题目', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          ...List.generate(_items.length, (i) {
            final (id, title, result) = _items[i];
            final isWrong = result == '错误';
            return GestureDetector(
              onTap: () => context.push(AppRoutes.questionDetailPath('mock')),
              child: Container(
                margin: EdgeInsets.only(bottom: i < _items.length - 1 ? 8 : 0),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Row(
                  children: [
                    Text(id, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(title, style: const TextStyle(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isWrong ? AppTheme.danger.withValues(alpha: 0.1) : AppTheme.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(result, style: TextStyle(fontSize: 12, color: isWrong ? AppTheme.danger : AppTheme.success)),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
