import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/providers/model_detail_provider.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';

class TrainingRecordListWidget extends ConsumerWidget {
  final String modelId;

  const TrainingRecordListWidget({super.key, required this.modelId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(modelDetailProvider(modelId));

    final records = async.when(
      loading: () => _fallbackRecords,
      error: (_, __) => _fallbackRecords,
      data: (data) {
        final total = data.errorCount + data.correctCount;
        if (total <= 0) return _fallbackRecords;

        final rate = (data.correctCount * 100 / total).round();
        final list = <_TrainingRecord>[
          _TrainingRecord(
            title: 'Step 1 训练',
            detail: '累计训练 $total 次 · 正确率 $rate%',
            passed: rate >= 60,
          ),
        ];

        if (data.errorCount > 0) {
          list.add(
            _TrainingRecord(
              title: '错题专项训练',
              detail: '近阶段错题 ${data.errorCount} 道 · 建议继续巩固',
              passed: false,
            ),
          );
        }

        return list;
      },
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('训练记录',
              style: AppTheme.heading(size: 18, weight: FontWeight.w900)),
          const SizedBox(height: 10),
          Column(
            children: [
              for (var i = 0; i < records.length; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                _buildItem(records[i]),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItem(_TrainingRecord record) {
    final statusColor = record.passed ? AppTheme.success : AppTheme.danger;

    return ClayCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Icon(
              record.passed ? Icons.check_rounded : Icons.close_rounded,
              size: 16,
              color: statusColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.title,
                  style: AppTheme.body(size: 14, weight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(record.detail, style: AppTheme.label(size: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static const _fallbackRecords = [
    _TrainingRecord(
        title: 'Step 1 训练', detail: '2月5日 · 未通过 · 识别失败', passed: false),
  ];
}

class _TrainingRecord {
  final String title;
  final String detail;
  final bool passed;

  const _TrainingRecord({
    required this.title,
    required this.detail,
    required this.passed,
  });
}
