import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/app/app_routes.dart';

class BoardMyRequestsWidget extends StatelessWidget {
  final List<CommunityRequest> requests;

  const BoardMyRequestsWidget({
    super.key,
    this.requests = const [
      CommunityRequest(title: '希望增加错题导出PDF功能', subtitle: '可以把错题按模型分组导出打印', votes: 23, tags: ['功能请求', '3天前'], highlight: true),
      CommunityRequest(title: '数学也需要过程拆分训练', subtitle: '解析几何大题特别需要过程拆分', votes: 45, tags: ['功能请求', '高票', '5天前'], highlight: true),
      CommunityRequest(title: '闪卡能不能支持手写公式', subtitle: '打字输入公式太麻烦了', votes: 8, tags: ['体验优化', '1周前'], highlight: false),
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppTheme.gradientPrimary,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              boxShadow: AppTheme.shadowClayButton,
            ),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusLg)),
                elevation: 0,
              ),
              child: Text('提交新需求',
                  style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 12),
          for (final item in requests) ...[
            _RequestCard(
              title: item.title,
              subtitle: item.subtitle,
              votes: item.votes,
              tags: item.tags,
              highlight: item.highlight,
              onTap: () => context.push(AppRoutes.communityDetail),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final String title, subtitle;
  final int votes;
  final List<String> tags;
  final bool highlight;
  final VoidCallback onTap;
  const _RequestCard({required this.title, required this.subtitle, required this.votes, required this.tags, required this.highlight, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClayCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
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
                    Text(title, style: AppTheme.body(size: 15, weight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(subtitle, style: AppTheme.label(size: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '$votes票',
                style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: highlight ? AppTheme.accent : AppTheme.muted),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            children: [
              for (final t in tags)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: t == '高票' ? AppTheme.accent.withValues(alpha: 0.1) : AppTheme.canvas,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Text(t, style: AppTheme.label(size: 11, color: t == '高票' ? AppTheme.accent : AppTheme.muted)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class CommunityRequest {
  final String title;
  final String subtitle;
  final int votes;
  final List<String> tags;
  final bool highlight;

  const CommunityRequest({
    required this.title,
    required this.subtitle,
    required this.votes,
    required this.tags,
    required this.highlight,
  });
}
