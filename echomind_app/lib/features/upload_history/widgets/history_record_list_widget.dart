import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/app/app_routes.dart';
import 'package:echomind_app/models/question.dart';
import 'package:echomind_app/providers/upload_history_provider.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';

class HistoryRecordListWidget extends ConsumerWidget {
  const HistoryRecordListWidget({super.key});

  static const _mockItems = [
    ('拍照上传', '2025-01-15 14:30', '已完成', true),
    ('手动录入', '2025-01-15 10:15', '已完成', true),
    ('拍照上传', '2025-01-14 16:45', '待诊断', false),
    ('拍照上传', '2025-01-12 09:20', '已完成', true),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(uploadHistoryProvider);

    return historyAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => _buildMockList(context),
      data: (groups) => groups.isEmpty
          ? _buildMockList(context)
          : _buildApiList(context, groups),
    );
  }

  Widget _buildApiList(BuildContext context, List<HistoryDateGroup> groups) {
    final records = <_HistoryRecord>[];

    for (final group in groups) {
      for (final question in group.questions) {
        records.add(_HistoryRecord(
          id: question.id.trim().isEmpty ? 'demo' : question.id,
          source: _sourceLabel(question.source),
          time: _displayTime(question.createdAt, group.date),
          status: _statusLabel(question.diagnosisStatus),
          done: _isDone(question.diagnosisStatus),
        ));
      }
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: records.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _buildCard(context, records[i]),
    );
  }

  Widget _buildMockList(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: _mockItems.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final (source, time, status, done) = _mockItems[i];
        return _buildCard(
          context,
          _HistoryRecord(
              id: 'demo',
              source: source,
              time: time,
              status: status,
              done: done),
        );
      },
    );
  }

  Widget _buildCard(BuildContext context, _HistoryRecord record) {
    return ClayCard(
      onTap: () => context.push(AppRoutes.questionDetailPath(record.id)),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: record.done
                  ? AppTheme.success.withValues(alpha: 0.14)
                  : AppTheme.accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(
              record.done ? Icons.check_rounded : Icons.schedule_rounded,
              size: 17,
              color: record.done ? AppTheme.success : AppTheme.accent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record.source,
                    style: AppTheme.body(size: 14, weight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text(record.time, style: AppTheme.label(size: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: (record.done ? AppTheme.success : AppTheme.warning)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Text(
              record.status,
              style: AppTheme.label(
                  size: 11,
                  color: record.done ? AppTheme.success : AppTheme.warning),
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right, size: 18, color: AppTheme.muted),
        ],
      ),
    );
  }

  String _sourceLabel(String raw) {
    final v = raw.trim().toLowerCase();
    if (v.contains('camera') || v.contains('拍照')) return '拍照上传';
    if (v.contains('manual') || v.contains('手动')) return '手动录入';
    if (v.isEmpty) return '错题上传';
    return raw;
  }

  String _displayTime(String? createdAt, String dateFallback) {
    final raw = (createdAt ?? '').trim();
    if (raw.isEmpty) return dateFallback;

    final normalized = raw.replaceFirst('T', ' ');
    if (normalized.length >= 16) {
      return normalized.substring(0, 16);
    }

    return normalized;
  }

  String _statusLabel(String raw) {
    final v = raw.trim().toLowerCase();
    if (v == 'completed' || v == 'done' || v.contains('完成')) return '已完成';
    if (v == 'pending' || v == 'active' || v.contains('待')) return '待诊断';
    return '待诊断';
  }

  bool _isDone(String raw) {
    final v = raw.trim().toLowerCase();
    return v == 'completed' || v == 'done' || v.contains('完成');
  }
}

class _HistoryRecord {
  final String id;
  final String source;
  final String time;
  final String status;
  final bool done;

  const _HistoryRecord({
    required this.id,
    required this.source,
    required this.time,
    required this.status,
    required this.done,
  });
}
