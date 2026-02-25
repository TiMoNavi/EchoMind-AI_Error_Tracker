import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';

class TrainingRecordListWidget extends StatelessWidget {
  final List<TrainingRecord> records;

  const TrainingRecordListWidget({
    super.key,
    this.records = const [
      TrainingRecord(title: 'Step 1 训练', detail: '2月5日 · 未通过 · 识别失败', passed: false),
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('训练记录', style: AppTheme.heading(size: 18)),
          const SizedBox(height: 10),
          Column(
            children: [
              for (int i = 0; i < records.length; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                _buildItem(records[i]),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItem(TrainingRecord r) {
    final Color statusColor = r.passed ? AppTheme.success : AppTheme.danger;
    return ClayCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Icon(
              r.passed ? Icons.check_rounded : Icons.close_rounded,
              size: 16, color: statusColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.title,
                    style: AppTheme.body(size: 14, weight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(r.detail, style: AppTheme.label(size: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TrainingRecord {
  final String title;
  final String detail;
  final bool passed;

  const TrainingRecord({
    required this.title,
    required this.detail,
    required this.passed,
  });
}
