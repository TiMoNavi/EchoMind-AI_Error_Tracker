import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/app/app_routes.dart';
import 'package:echomind_app/providers/prediction_provider.dart';

class ScorePathTableWidget extends ConsumerWidget {
  const ScorePathTableWidget({super.key});

  static const _mockItems = [
    ScorePathItem(questionLabel: '第5题', score: '6分', modelName: '受力分析', modelId: 'mock', priority: '高'),
    ScorePathItem(questionLabel: '第12题', score: '4分', modelName: '运动学', modelId: 'mock', priority: '中'),
    ScorePathItem(questionLabel: '第8题', score: '3分', modelName: '能量守恒', modelId: 'mock', priority: '中'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prediction = ref.watch(predictionProvider);

    final items = prediction.whenOrNull(
      data: (d) => d.scorePath.isNotEmpty ? d.scorePath : null,
    ) ?? _mockItems;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('提分路径', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
            child: Column(children: [
              _header(),
              for (var i = 0; i < items.length; i++)
                _row(context, items[i], i < items.length - 1),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.divider, width: 0.5))),
      child: const Row(children: [
        Expanded(flex: 2, child: Text('题号', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary))),
        Expanded(flex: 2, child: Text('可提分', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary))),
        Expanded(flex: 3, child: Text('关联模型', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary))),
        Expanded(flex: 1, child: Text('优先级', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary))),
      ]),
    );
  }

  Widget _row(BuildContext context, ScorePathItem item, bool hasBorder) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.modelDetailPath(item.modelId)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: hasBorder ? const BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.divider, width: 0.5))) : null,
        child: Row(children: [
          Expanded(flex: 2, child: Text(item.questionLabel, style: const TextStyle(fontSize: 13))),
          Expanded(flex: 2, child: Text(item.score, style: const TextStyle(fontSize: 13, color: AppTheme.primary))),
          Expanded(flex: 3, child: Text(item.modelName, style: const TextStyle(fontSize: 13))),
          Expanded(
            flex: 1,
            child: Text(item.priority, style: TextStyle(fontSize: 12, color: item.priority == '高' ? AppTheme.danger : AppTheme.textSecondary)),
          ),
        ]),
      ),
    );
  }
}
