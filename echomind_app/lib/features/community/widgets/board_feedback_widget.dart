import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/providers/community_provider.dart';
import 'package:echomind_app/models/community.dart' as community_models;

class BoardFeedbackWidget extends ConsumerStatefulWidget {
  const BoardFeedbackWidget({super.key});

  @override
  ConsumerState<BoardFeedbackWidget> createState() =>
      _BoardFeedbackWidgetState();
}

class _BoardFeedbackWidgetState extends ConsumerState<BoardFeedbackWidget> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(communityProvider.notifier).fetchFeedbacks());
  }

  void _showSubmitDialog() {
    final contentCtrl = TextEditingController();
    String selectedType = 'suggestion';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('提交反馈'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(labelText: '反馈类型'),
                items: const [
                  DropdownMenuItem(value: 'suggestion', child: Text('改进建议')),
                  DropdownMenuItem(value: 'bug', child: Text('Bug 报告')),
                  DropdownMenuItem(value: 'praise', child: Text('好评')),
                  DropdownMenuItem(value: 'other', child: Text('其他')),
                ],
                onChanged: (v) =>
                    setDialogState(() => selectedType = v ?? 'suggestion'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentCtrl,
                decoration: const InputDecoration(
                  labelText: '反馈内容',
                  hintText: '详细描述你的反馈',
                ),
                maxLines: 4,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () async {
                if (contentCtrl.text.trim().isEmpty) return;
                Navigator.pop(ctx);
                final ok = await ref
                    .read(communityProvider.notifier)
                    .submitFeedback(
                      content: contentCtrl.text.trim(),
                      feedbackType: selectedType,
                    );
                if (mounted && !ok) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('提交失败，请重试')),
                  );
                }
              },
              child: const Text('提交'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(communityProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // 提交按钮
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: state.isSubmitting ? null : _showSubmitDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                elevation: 0,
              ),
              child: state.isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('提交反馈'),
            ),
          ),
          const SizedBox(height: 12),
          // 三态 UI
          if (state.isLoading && state.feedbacks.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (state.feedbacks.isEmpty)
            _buildEmpty()
          else
            ...state.feedbacks.map((f) => _FeedbackCard(feedback: f)),
        ],
      ),
    );
  }

  Widget _buildEmpty() => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: const Column(
          children: [
            Text('💬', style: TextStyle(fontSize: 36)),
            SizedBox(height: 12),
            Text('还没有反馈',
                style: TextStyle(fontSize: 15, color: AppTheme.textSecondary)),
            SizedBox(height: 4),
            Text('点击上方按钮提交你的第一条反馈',
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          ],
        ),
      );
}

class _FeedbackCard extends StatelessWidget {
  final community_models.Feedback feedback;
  const _FeedbackCard({required this.feedback});

  static const _typeLabels = {
    'suggestion': '改进建议',
    'bug': 'Bug',
    'praise': '好评',
    'other': '其他',
  };

  static const _typeColors = {
    'suggestion': AppTheme.primary,
    'bug': AppTheme.danger,
    'praise': AppTheme.success,
    'other': AppTheme.textSecondary,
  };

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}天前';
    if (diff.inHours > 0) return '${diff.inHours}小时前';
    return '刚刚';
  }

  @override
  Widget build(BuildContext context) {
    final color = _typeColors[feedback.feedbackType] ?? AppTheme.textSecondary;
    final label = _typeLabels[feedback.feedbackType] ?? feedback.feedbackType;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(feedback.content,
              style: const TextStyle(fontSize: 14, height: 1.4),
              maxLines: 4,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(label,
                    style: TextStyle(fontSize: 11, color: color)),
              ),
              const SizedBox(width: 8),
              Text(_timeAgo(feedback.createdAt),
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}
