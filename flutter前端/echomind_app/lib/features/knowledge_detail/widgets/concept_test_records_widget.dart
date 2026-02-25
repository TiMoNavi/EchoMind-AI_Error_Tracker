import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';

class ConceptTestRecordsWidget extends StatelessWidget {
  final List<ConceptTestRecord> records;

  const ConceptTestRecordsWidget({
    super.key,
    this.records = const [
      ConceptTestRecord(name: '检测 #3', desc: '2月9日 · 未通过 · 条件判断错误', passed: false),
      ConceptTestRecord(name: '检测 #2', desc: '2月5日 · 通过 · 全部正确', passed: true),
      ConceptTestRecord(name: '检测 #1', desc: '1月28日 · 通过 · 2/3正确', passed: true),
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('概念检测记录', style: AppTheme.heading(size: 18)),
          const SizedBox(height: 10),
          _listGroup(),
        ],
      ),
    );
  }

  Widget _listGroup() {
    return Column(
      children: [
        for (var i = 0; i < records.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _buildItem(records[i]),
        ],
      ],
    );
  }

  static Widget _buildItem(ConceptTestRecord item) {
    final Color statusColor = item.passed ? AppTheme.success : AppTheme.danger;
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
              item.passed ? Icons.check_rounded : Icons.close_rounded,
              size: 16, color: statusColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: AppTheme.body(size: 14, weight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(item.desc, style: AppTheme.label(size: 12)),
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