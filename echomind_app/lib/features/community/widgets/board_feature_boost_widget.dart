import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/providers/community_provider.dart';
import 'package:echomind_app/models/community.dart';

class BoardFeatureBoostWidget extends ConsumerStatefulWidget {
  const BoardFeatureBoostWidget({super.key});

  @override
  ConsumerState<BoardFeatureBoostWidget> createState() =>
      _BoardFeatureBoostWidgetState();
}

class _BoardFeatureBoostWidgetState
    extends ConsumerState<BoardFeatureBoostWidget> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(communityProvider.notifier).fetchRequests());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(communityProvider);

    // 按票数降序排列
    final sorted = [...state.requests]
      ..sort((a, b) => b.voteCount.compareTo(a.voteCount));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          if (state.isLoading && state.requests.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (state.requests.isEmpty)
            _buildEmpty()
          else
            ...sorted.asMap().entries.map((e) => _BoostCard(
                  rank: e.key + 1,
                  request: e.value,
                  onVote: () => ref
                      .read(communityProvider.notifier)
                      .toggleVote(e.value.id),
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
            Text('🚀', style: TextStyle(fontSize: 36)),
            SizedBox(height: 12),
            Text('暂无功能需求',
                style: TextStyle(fontSize: 15, color: AppTheme.textSecondary)),
            SizedBox(height: 4),
            Text('去"我的需求"板块提交第一个需求吧',
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          ],
        ),
      );
}

class _BoostCard extends StatelessWidget {
  final int rank;
  final FeatureRequest request;
  final VoidCallback onVote;
  const _BoostCard({
    required this.rank,
    required this.request,
    required this.onVote,
  });

  @override
  Widget build(BuildContext context) {
    final isTop3 = rank <= 3;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: isTop3
            ? Border.all(
                color: AppTheme.primary.withValues(alpha: 0.3), width: 1)
            : null,
      ),
      child: Row(
        children: [
          // 排名
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isTop3
                  ? AppTheme.primary.withValues(alpha: 0.1)
                  : AppTheme.background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              '$rank',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isTop3 ? AppTheme.primary : AppTheme.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 内容
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(request.title,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                if (request.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(request.description,
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          // 投票按钮
          _VoteButton(
            count: request.voteCount,
            voted: request.voted,
            onTap: onVote,
          ),
        ],
      ),
    );
  }
}

class _VoteButton extends StatelessWidget {
  final int count;
  final bool voted;
  final VoidCallback onTap;
  const _VoteButton({
    required this.count,
    required this.voted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: voted
              ? AppTheme.primary.withValues(alpha: 0.1)
              : AppTheme.background,
          borderRadius: BorderRadius.circular(20),
          border: voted
              ? Border.all(color: AppTheme.primary.withValues(alpha: 0.3))
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              voted ? Icons.thumb_up : Icons.thumb_up_outlined,
              size: 16,
              color: voted ? AppTheme.primary : AppTheme.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: voted ? AppTheme.primary : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}