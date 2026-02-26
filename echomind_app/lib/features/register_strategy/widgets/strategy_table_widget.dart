import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/providers/strategy_provider.dart';

class StrategyTableWidget extends ConsumerWidget {
  const StrategyTableWidget({super.key});

  // 态度色块映射
  static const _attitudeColors = {
    'must': Color(0xFFE53935),
    'try': Color(0xFFFFA726),
    'skip': Color(0xFFBDBDBD),
  };

  static const _attitudeLabels = {
    'must': '必须拿满',
    'try': '争取拿分',
    'skip': '可放弃',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(strategyProvider);
    final strategies = state.strategy?.questionStrategies ?? [];
    if (strategies.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Text('卷面策略表',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
            ),
            // 图例
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildLegend(),
            ),
            const SizedBox(height: 8),
            // 表头
            _buildTableHeader(),
            const Divider(height: 1, indent: 16, endIndent: 16),
            // 表体
            ...strategies.map((s) => _buildTableRow(s)),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 12,
      children: _attitudeColors.entries.map((e) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: e.value,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 4),
            Text(_attitudeLabels[e.key] ?? '',
                style: const TextStyle(
                    fontSize: 11, color: AppTheme.textSecondary)),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildTableHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
              flex: 4,
              child: Text('题号/区域',
                  style: TextStyle(
                      fontSize: 12, color: AppTheme.textSecondary))),
          Expanded(
              flex: 2,
              child: Text('满分',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12, color: AppTheme.textSecondary))),
          Expanded(
              flex: 2,
              child: Text('目标',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12, color: AppTheme.textSecondary))),
          Expanded(
              flex: 2,
              child: Text('态度',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12, color: AppTheme.textSecondary))),
        ],
      ),
    );
  }

  Widget _buildTableRow(QuestionStrategy s) {
    final color = _attitudeColors[s.attitude] ?? Colors.grey;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 4,
                child: Text(s.questionRange,
                    style: const TextStyle(fontSize: 13)),
              ),
              Expanded(
                flex: 2,
                child: Text('${s.maxScore}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13)),
              ),
              Expanded(
                flex: 2,
                child: Text('${s.targetScore}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: color)),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // 显示文案
          if (s.displayText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(s.displayText,
                    style: TextStyle(
                        fontSize: 11, color: color, height: 1.3)),
              ),
            ),
        ],
      ),
    );
  }
}
