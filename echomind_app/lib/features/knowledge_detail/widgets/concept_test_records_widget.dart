import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';
import 'package:echomind_app/providers/knowledge_detail_provider.dart';

class ConceptTestRecordsWidget extends ConsumerWidget {
  final String kpId;

  const ConceptTestRecordsWidget({super.key, required this.kpId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(knowledgeDetailProvider(kpId));
    return async.when(
      loading: () => const SizedBox(
        height: 80,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (data) {
        final total = data.errorCount + data.correctCount;
        final accuracy =
            total > 0 ? '${(data.correctCount * 100 / total).round()}%' : '--';

        final records = <ConceptTestRecord>[
          ConceptTestRecord(
            name: '最近一次检测',
            desc: '错题 ${data.errorCount} · 正确 ${data.correctCount}',
            passed: data.errorCount <= data.correctCount,
          ),
          ConceptTestRecord(
            name: '整体正确率',
            desc: '正确率 $accuracy',
            passed: data.correctCount >= data.errorCount,
          ),
          ConceptTestRecord(
            name: '累计检测次数',
            desc: '共 $total 次',
            passed: total > 0,
          ),
        ];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '概念检测记录',
                style: AppTheme.heading(size: 20, weight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              Column(
                children: [
                  for (var i = 0; i < records.length; i++) ...[
                    if (i > 0) const SizedBox(height: 10),
                    _item(records[i]),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _item(ConceptTestRecord record) {
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
                  record.name,
                  style: AppTheme.body(size: 14, weight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(record.desc, style: AppTheme.label(size: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ConceptTestRecord {
  final String name;
  final String desc;
  final bool passed;

  const ConceptTestRecord({
    required this.name,
    required this.desc,
    required this.passed,
  });
}
