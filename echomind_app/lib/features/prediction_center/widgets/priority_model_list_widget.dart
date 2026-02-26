import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/app/app_routes.dart';
import 'package:echomind_app/providers/prediction_provider.dart';

class PriorityModelListWidget extends ConsumerWidget {
  const PriorityModelListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prediction = ref.watch(predictionProvider);

    return prediction.when(
      loading: () => const SizedBox(
          height: 80, child: Center(child: CircularProgressIndicator())),
      error: (_, __) => const SizedBox.shrink(),
      data: (d) => _buildList(context, d.priorityModels),
    );
  }

  Widget _buildList(BuildContext context, List<PriorityModel> items) {
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          child: const Row(children: [
            Icon(Icons.info_outline, size: 18, color: AppTheme.textSecondary),
            SizedBox(width: 8),
            Text('上传更多题目后将生成训练建议',
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          ]),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('优先训练模型',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
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
