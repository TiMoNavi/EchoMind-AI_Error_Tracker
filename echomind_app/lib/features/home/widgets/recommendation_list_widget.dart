import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/app/app_routes.dart';
import 'package:echomind_app/providers/recommendations_provider.dart';

class RecommendationListWidget extends ConsumerWidget {
  const RecommendationListWidget({super.key});

  static const _mockItems = [
    (icon: '!', title: '待诊断: 2025天津模拟 第5题', tags: ['待诊断', '上传于今日'], route: AppRoutes.aiDiagnosis),
    (icon: 'L1', title: '板块运动 -- 建模层训练', tags: ['本周错2次', '约5分钟'], route: AppRoutes.modelDetail),
    (icon: 'KP', title: '库仑定律适用条件 -- 知识补强', tags: ['理解不深', '约3分钟'], route: AppRoutes.knowledgeDetail),
    (icon: '~', title: '牛顿第二定律应用 -- 不稳定', tags: ['掌握不稳定', '14天未练习'], route: AppRoutes.modelDetail),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recs = ref.watch(recommendationsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('推荐学习', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          recs.when(
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())),
            error: (_, __) => _buildMockList(context),
            data: (items) => items.isEmpty ? _buildMockList(context) : _buildApiList(context, items),
          ),
        ],
      ),
    );
  }

  Widget _buildApiList(BuildContext context, List<RecommendationItem> items) {
    return Column(children: [
      for (final item in items)
        _RecItem(
          icon: item.targetType == 'knowledge' ? 'KP' : 'L${item.currentLevel}',
          color: item.isUnstable ? AppTheme.danger : AppTheme.primary,
          title: item.targetName,
          tags: [
            if (item.errorCount > 0) '错${item.errorCount}次',
            if (item.isUnstable) '不稳定',
            'L${item.currentLevel}',
          ],
          onTap: () => context.push(
            item.targetType == 'knowledge'
                ? AppRoutes.knowledgeDetailPath(item.targetId)
                : AppRoutes.modelDetailPath(item.targetId),
          ),
        ),
    ]);
  }

  Widget _buildMockList(BuildContext context) {
    return Column(children: [
      for (final item in _mockItems)
        _RecItem(icon: item.icon, color: AppTheme.primary, title: item.title, tags: item.tags, onTap: () => context.push(item.route)),
    ]);
  }
}

class _RecItem extends StatelessWidget {
  final String icon;
  final Color color;
  final String title;
  final List<String> tags;
  final VoidCallback onTap;
  const _RecItem({required this.icon, required this.color, required this.title, required this.tags, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
            alignment: Alignment.center,
            child: Text(icon, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Wrap(spacing: 6, children: [for (final t in tags) _Tag(t)]),
            ],
          )),
          const Icon(Icons.chevron_right, size: 20, color: AppTheme.textSecondary),
        ]),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  const _Tag(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(4)),
      child: Text(text, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
    );
  }
}
