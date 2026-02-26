import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/providers/community_provider.dart';
import 'package:echomind_app/models/community.dart';

class BoardMyRequestsWidget extends ConsumerStatefulWidget {
  const BoardMyRequestsWidget({super.key});

  @override
  ConsumerState<BoardMyRequestsWidget> createState() =>
      _BoardMyRequestsWidgetState();
}

class _BoardMyRequestsWidgetState
    extends ConsumerState<BoardMyRequestsWidget> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(communityProvider.notifier).fetchRequests());
  }

  void _showSubmitDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String? selectedTag;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('提交新需求'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: '标题',
                  hintText: '简要描述你的需求',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(
                  labelText: '详细描述',
                  hintText: '详细说明你希望实现的功能',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedTag,
                decoration: const InputDecoration(labelText: '标签（可选）'),
                items: const [
                  DropdownMenuItem(value: '功能请求', child: Text('功能请求')),
                  DropdownMenuItem(value: '体验优化', child: Text('体验优化')),
                  DropdownMenuItem(value: 'UI', child: Text('UI')),
                  DropdownMenuItem(value: '其他', child: Text('其他')),
                ],
                onChanged: (v) => setDialogState(() => selectedTag = v),
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
                if (titleCtrl.text.trim().isEmpty) return;
                Navigator.pop(ctx);
                final ok = await ref
                    .read(communityProvider.notifier)
                    .submitRequest(
                      title: titleCtrl.text.trim(),
                      description: descCtrl.text.trim(),
                      tag: selectedTag,
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
                  : const Text('提交新需求'),
            ),
          ),
          const SizedBox(height: 12),
          // 三态 UI
          if (state.isLoading && state.requests.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (state.errorMessage != null && state.requests.isEmpty)
            _buildError(state.errorMessage!)
          else if (state.requests.isEmpty)
            _buildEmpty()
          else
            ...state.requests.map((r) => _RequestCard(
                  request: r,
                  onVote: () => ref
                      .read(communityProvider.notifier)
                      .toggleVote(r.id),
                )),
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
            Text('📝', style: TextStyle(fontSize: 36)),
            SizedBox(height: 12),
            Text('还没有需求', style: TextStyle(fontSize: 15, color: AppTheme.textSecondary)),
            SizedBox(height: 4),
            Text('点击上方按钮提交你的第一个需求',
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          ],
        ),
      );

  Widget _buildError(String msg) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Column(
          children: [
            const Text('⚠️', style: TextStyle(fontSize: 36)),
            const SizedBox(height: 12),
            Text('加载失败', style: const TextStyle(fontSize: 15, color: AppTheme.danger)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => ref.read(communityProvider.notifier).fetchRequests(),
              child: const Text('重试'),
            ),
          ],
        ),
      );
}

class _RequestCard extends StatelessWidget {
  final FeatureRequest request;
  final VoidCallback onVote;
  const _RequestCard({required this.request, required this.onVote});

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}天前';
    if (diff.inHours > 0) return '${diff.inHours}小时前';
    return '刚刚';
  }

  @override
  Widget build(BuildContext context) {
    final highlight = request.voteCount >= 10;
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(request.title,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(request.description,
                        style: const TextStyle(
                            fontSize: 13, color: AppTheme.textSecondary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // 投票按钮
              GestureDetector(
                onTap: onVote,
                child: Column(
                  children: [
                    Icon(
                      request.voted
                          ? Icons.thumb_up
                          : Icons.thumb_up_outlined,
                      size: 20,
                      color: request.voted
                          ? AppTheme.primary
                          : AppTheme.textSecondary,
                    ),
                    const SizedBox(height: 2),
                    Text('${request.voteCount}',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: highlight
                                ? AppTheme.primary
                                : AppTheme.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: [
              if (request.tag != null)
                _tag(request.tag!, false),
              if (highlight) _tag('高票', true),
              _tag(_timeAgo(request.createdAt), false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tag(String text, bool isPrimary) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: isPrimary
              ? AppTheme.primary.withValues(alpha: 0.1)
              : AppTheme.background,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(text,
            style: TextStyle(
                fontSize: 11,
                color:
                    isPrimary ? AppTheme.primary : AppTheme.textSecondary)),
      );
}