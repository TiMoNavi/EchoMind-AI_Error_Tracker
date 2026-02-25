import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/app/app_routes.dart';

class HistoryRecordListWidget extends StatelessWidget {
  final Map<String, List<HistoryRecord>> groupedRecords;

  const HistoryRecordListWidget({
    super.key,
    this.groupedRecords = _defaultRecords,
  });

  static const Map<String, List<HistoryRecord>> _defaultRecords = {
    '今天': [
      HistoryRecord('HW', Color(0xFF1C1C1E), '作业 -- 力学练习',
          '3道错题 -- 1道已诊断, 2道待诊断', '14:30', '2待诊断', true),
    ],
    '2月8日': [
      HistoryRecord('EX', AppTheme.accent, '2025天津模拟卷(一)',
          '6道错题 -- 3道待诊断', '10:15', '3待诊断', true),
    ],
    '2月5日': [
      HistoryRecord('HW', Color(0xFF1C1C1E), '作业 -- 电场练习',
          '2道错题 -- 全部已诊断', '16:42', '已完成', false),
    ],
    '2月3日': [
      HistoryRecord('EX', AppTheme.accent, '2024天津高考真题',
          '8道错题 -- 全部已诊断', '09:30', '已完成', false),
      HistoryRecord('QK', Color(0xFF636366), '极简上传 -- 5道题',
          '1道错题 -- 已诊断', '20:10', '已完成', false),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return ListView(
      clipBehavior: Clip.none,
      padding: const EdgeInsets.only(bottom: 40),
      children: [
        for (final entry in groupedRecords.entries) ...[
          _dateHeader(entry.key),
          _group(context, entry.value),
        ],
      ],
    );
  }

  static Widget _dateHeader(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
      child: Text(label, style: AppTheme.label(size: 13)),
    );
  }

  Widget _group(BuildContext context, List<HistoryRecord> records) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          for (var i = 0; i < records.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _buildItem(context, records[i]),
          ],
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, HistoryRecord r) {
    return ClayCard(
      onTap: () => context.push(AppRoutes.questionDetail),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: r.iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(r.iconLabel,
                style: AppTheme.label(size: 10, color: Colors.white)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.title, style: AppTheme.body(size: 14, weight: FontWeight.w600)),
                const SizedBox(height: 3),
                Text(r.desc, style: AppTheme.label(size: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(r.time, style: AppTheme.label(size: 11)),
              const SizedBox(height: 3),
              _statusTag(r.status, r.isPending),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _statusTag(String label, bool isPending) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: isPending ? AppTheme.accent : AppTheme.success,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Text(label,
          style: AppTheme.label(size: 9, color: Colors.white)),
    );
  }
}

class HistoryRecord {
  final String iconLabel;
  final Color iconBg;
  final String title;
  final String desc;
  final String time;
  final String status;
  final bool isPending;

  const HistoryRecord(this.iconLabel, this.iconBg, this.title,
      this.desc, this.time, this.status, this.isPending);
}