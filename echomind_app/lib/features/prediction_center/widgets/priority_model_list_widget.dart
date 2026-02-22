import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/app/app_routes.dart';
import 'package:echomind_app/providers/prediction_provider.dart';

class PriorityModelListWidget extends ConsumerWidget {
  const PriorityModelListWidget({super.key});

  static const _mockItems = [
    PriorityModel(modelId: 'mock', modelName: '受力分析', level: 3, description: '预计提分 6 分'),
    PriorityModel(modelId: 'mock', modelName: '运动学', level: 2, description: '预计提分 4 分'),
    PriorityModel(modelId: 'mock', modelName: '能量守恒', level: 2, description: '预计提分 3 分'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prediction = ref.watch(predictionProvider);

    final items = prediction.whenOrNull(
      data: (d) => d.priorityModels.isNotEmpty ? d.priorityModels : null,
    ) ?? _mockItems;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('优先训练模型', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          for (var i = 0; i < items.length; i++)
            _item(context, items[i], i < items.length - 1),
        ],
      ),
    );
  }

  Widget _item(BuildContext context, PriorityModel m, bool hasMargin) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.modelDetailPath(m.modelId)),
      child: Container(
        margin: EdgeInsets.only(bottom: hasMargin ? 8 : 0),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
        child: Row(children: [
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(m.modelName, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 2),
              Text(m.description, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            ],
          )),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
            child: Text('L${m.level}', style: const TextStyle(fontSize: 12, color: AppTheme.primary)),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, size: 18, color: AppTheme.textSecondary),
        ]),
      ),
    );
  }
}
