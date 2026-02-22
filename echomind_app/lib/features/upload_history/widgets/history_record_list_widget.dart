import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/app/app_routes.dart';
import 'package:echomind_app/models/question.dart';
import 'package:echomind_app/providers/upload_history_provider.dart';

class HistoryRecordListWidget extends ConsumerWidget {
  const HistoryRecordListWidget({super.key});

  static const _mockItems = [
    ('拍照上传', '2025-01-15 14:30', '已处理', '3道题'),
    ('手动录入', '2025-01-15 10:15', '已处理', '1道题'),
    ('拍照上传', '2025-01-14 16:45', '待处理', '5道题'),
    ('拍照上传', '2025-01-12 09:20', '已处理', '2道题'),
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
    final allQuestions = groups.expand((g) => g.questions.map((q) => (g.date, q))).toList();
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: allQuestions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final (date, q) = allQuestions[i];
        final done = q.diagnosisStatus == 'completed';
        final status = done ? '已处理' : '待处理';
        return _card(
          context,
          type: q.source,
          time: q.createdAt ?? date,
          status: status,
          done: done,
        );
      },
    );
  }

  Widget _buildMockList(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: _mockItems.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final (type, time, status, _) = _mockItems[i];
        return _card(context, type: type, time: time, status: status, done: status == '已处理');
      },
    );
  }

  Widget _card(BuildContext context, {
    required String type, required String time, required String status, required bool done,
  }) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.questionDetailPath('mock')),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Row(children: [
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(type, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 2),
              Text(time, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            ],
          )),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: done ? AppTheme.success.withValues(alpha: 0.1) : AppTheme.danger.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(status, style: TextStyle(fontSize: 12, color: done ? AppTheme.success : AppTheme.danger)),
          ),
        ]),
      ),
    );
  }
}
