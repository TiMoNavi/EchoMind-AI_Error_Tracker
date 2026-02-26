import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/providers/prediction_provider.dart';

class ScorePathTableWidget extends ConsumerWidget {
  const ScorePathTableWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prediction = ref.watch(predictionProvider);

    final items = prediction.whenOrNull(
      data: (d) => d.scorePath.isNotEmpty ? d.scorePath : null,
    ) ?? const <ScorePathItem>[];

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
                _row(items[i], i < items.length - 1),
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
        Expanded(flex: 3, child: Text('能力维度', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary))),
        Expanded(flex: 2, child: Text('当前', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary))),
        Expanded(flex: 2, child: Text('目标', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary))),
        Expanded(flex: 2, child: Text('差距', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary))),
      ]),
    );
  }

  Widget _row(ScorePathItem item, bool hasBorder) {
    final gap = item.gap;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: hasBorder ? const BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.divider, width: 0.5))) : null,
      child: Row(children: [
        Expanded(flex: 3, child: Text(item.label, style: const TextStyle(fontSize: 13))),
        Expanded(flex: 2, child: Text('${(item.current * 100).toInt()}%', style: const TextStyle(fontSize: 13, color: AppTheme.primary))),
        Expanded(flex: 2, child: Text('${(item.target * 100).toInt()}%', style: const TextStyle(fontSize: 13))),
        Expanded(
          flex: 2,
          child: Text(
            gap > 0 ? '-${(gap * 100).toInt()}%' : '✅',
            style: TextStyle(fontSize: 12, color: gap > 0 ? AppTheme.danger : AppTheme.success),
          ),
        ),
      ]),
    );
  }
}
