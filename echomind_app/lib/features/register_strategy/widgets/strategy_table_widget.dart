import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/providers/strategy_provider.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';

class StrategyTableWidget extends ConsumerWidget {
  const StrategyTableWidget({super.key});

  static const _attitudeColors = {
    'must': AppTheme.danger,
    'try': AppTheme.warning,
    'skip': AppTheme.muted,
  };

  static const _attitudeLabels = {
    'must': '必须拿满',
    'try': '争取拿分',
    'skip': '可放弃',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(strategyProvider);
    final strategies =
        state.strategy?.questionStrategies ?? const <QuestionStrategy>[];

    if (strategies.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClayCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('卷面策略表',
                style: AppTheme.heading(size: 18, weight: FontWeight.w900)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: _attitudeColors.entries.map((entry) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: entry.value,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(_attitudeLabels[entry.key] ?? '',
                        style: AppTheme.label(size: 11)),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            _buildHeader(),
            const SizedBox(height: 6),
            for (var i = 0; i < strategies.length; i++) ...[
              if (i > 0) const Divider(height: 10, color: AppTheme.divider),
              _buildRow(strategies[i]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
            flex: 4, child: Text('题号/区间', style: AppTheme.label(size: 11))),
        Expanded(
            flex: 2,
            child: Text('满分',
                textAlign: TextAlign.center, style: AppTheme.label(size: 11))),
        Expanded(
            flex: 2,
            child: Text('目标',
                textAlign: TextAlign.center, style: AppTheme.label(size: 11))),
        Expanded(
            flex: 3,
            child: Text('态度',
                textAlign: TextAlign.center, style: AppTheme.label(size: 11))),
      ],
    );
  }

  Widget _buildRow(QuestionStrategy strategy) {
    final attitudeKey = strategy.attitude.trim().toLowerCase();
    final color = _attitudeColors[attitudeKey] ?? AppTheme.muted;
    final label = _attitudeLabels[attitudeKey] ?? strategy.attitude;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              flex: 4,
              child: Text(strategy.questionRange,
                  style: AppTheme.body(size: 13, weight: FontWeight.w700)),
            ),
            Expanded(
              flex: 2,
              child: Text('${strategy.maxScore}',
                  textAlign: TextAlign.center,
                  style: AppTheme.body(size: 13, weight: FontWeight.w700)),
            ),
            Expanded(
              flex: 2,
              child: Text('${strategy.targetScore}',
                  textAlign: TextAlign.center,
                  style: AppTheme.body(
                      size: 13, weight: FontWeight.w800, color: color)),
            ),
            Expanded(
              flex: 3,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Text(label,
                      style: AppTheme.label(size: 11, color: color)),
                ),
              ),
            ),
          ],
        ),
        if (strategy.displayText.trim().isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(strategy.displayText,
              style: AppTheme.label(size: 11, color: color)),
        ],
      ],
    );
  }
}
