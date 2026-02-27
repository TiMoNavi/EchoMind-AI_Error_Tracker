import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/providers/prediction_provider.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';

class ScorePathTableWidget extends ConsumerWidget {
  const ScorePathTableWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prediction = ref.watch(predictionProvider);

    final items = prediction.whenOrNull(data: (d) => d.scorePath) ??
        const <ScorePathItem>[];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('提分路径',
              style: AppTheme.heading(size: 18, weight: FontWeight.w900)),
          const SizedBox(height: 12),
          if (items.isEmpty)
            ClayCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      size: 18, color: AppTheme.muted),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text('暂无提分路径数据',
                          style: AppTheme.body(
                              size: 13, weight: FontWeight.w700))),
                ],
              ),
            )
          else
            ClayCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 8),
                  for (var i = 0; i < items.length; i++) ...[
                    if (i > 0)
                      const Divider(height: 10, color: AppTheme.divider),
                    _buildRow(items[i]),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(flex: 3, child: Text('能力维度', style: AppTheme.label(size: 11))),
        Expanded(flex: 2, child: Text('当前', style: AppTheme.label(size: 11))),
        Expanded(flex: 2, child: Text('目标', style: AppTheme.label(size: 11))),
        Expanded(flex: 2, child: Text('差距', style: AppTheme.label(size: 11))),
      ],
    );
  }

  Widget _buildRow(ScorePathItem item) {
    final currentPct = (item.current * 100).round();
    final targetPct = (item.target * 100).round();
    final gap = item.gap;
    final isNeedUp = gap > 0;

    return Row(
      children: [
        Expanded(
            flex: 3,
            child: Text(item.label,
                style: AppTheme.body(size: 13, weight: FontWeight.w700))),
        Expanded(
            flex: 2,
            child: Text('$currentPct%',
                style: AppTheme.body(
                    size: 12,
                    weight: FontWeight.w700,
                    color: AppTheme.accent))),
        Expanded(
            flex: 2,
            child: Text('$targetPct%',
                style: AppTheme.body(size: 12, weight: FontWeight.w700))),
        Expanded(
          flex: 2,
          child: Text(
            isNeedUp ? '-${(gap * 100).round()}%' : '已达标',
            style: AppTheme.label(
                size: 11, color: isNeedUp ? AppTheme.danger : AppTheme.success),
          ),
        ),
      ],
    );
  }
}
