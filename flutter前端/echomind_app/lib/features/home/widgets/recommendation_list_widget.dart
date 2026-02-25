import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/app/app_routes.dart';

class RecommendationListWidget extends StatelessWidget {
  const RecommendationListWidget({super.key});

  static const _items = [
    (
      icon: Icons.error_outline_rounded,
      gradient: AppTheme.gradientPink,
      title: '待诊断: 2025天津模拟 第5题',
      tags: ['待诊断', '上传于今日'],
      route: AppRoutes.aiDiagnosis,
      isUrgent: true,
    ),
    (
      icon: Icons.layers_rounded,
      gradient: AppTheme.gradientPrimary,
      title: '板块运动 — 建模层训练',
      tags: ['本周错2次', '约5分钟'],
      route: AppRoutes.modelDetail,
      isUrgent: false,
    ),
    (
      icon: Icons.lightbulb_outline_rounded,
      gradient: AppTheme.gradientBlue,
      title: '库仑定律适用条件 — 知识补强',
      tags: ['理解不深', '约3分钟'],
      route: AppRoutes.knowledgeDetail,
      isUrgent: false,
    ),
    (
      icon: Icons.show_chart_rounded,
      gradient: AppTheme.gradientGreen,
      title: '牛顿第二定律应用 — 不稳定',
      tags: ['掌握不稳定', '14天未练习'],
      route: AppRoutes.modelDetail,
      isUrgent: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('推荐学习', style: AppTheme.heading(size: 20, weight: FontWeight.w800)),
          const SizedBox(height: 12),
          for (final item in _items)
            item.isUrgent
                ? _UrgentRecItem(
                    icon: item.icon,
                    gradient: item.gradient,
                    title: item.title,
                    tags: item.tags,
                    onTap: () => context.push(item.route),
                  )
                : _RecItem(
                    icon: item.icon,
                    gradient: item.gradient,
                    title: item.title,
                    tags: item.tags,
                    onTap: () => context.push(item.route),
                  ),
        ],
      ),
    );
  }
}

// ─── Urgent Recommendation Item (pink left border, larger) ───
class _UrgentRecItem extends StatelessWidget {
  final IconData icon;
  final LinearGradient gradient;
  final String title;
  final List<String> tags;
  final VoidCallback onTap;
  const _UrgentRecItem({
    required this.icon,
    required this.gradient,
    required this.title,
    required this.tags,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            boxShadow: AppTheme.shadowClayCard,
            border: const Border(
              left: BorderSide(color: Color(0xFFDB2777), width: 4),
            ),
          ),
          child: Row(
            children: [
              // Larger gradient icon orb
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(4, 4),
                      blurRadius: 10,
                      color: gradient.colors.last.withValues(alpha: 0.3),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.body(size: 16).copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      children: [for (final t in tags) _Tag(t)],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: AppTheme.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Normal Recommendation Item ───
class _RecItem extends StatelessWidget {
  final IconData icon;
  final LinearGradient gradient;
  final String title;
  final List<String> tags;
  final VoidCallback onTap;
  const _RecItem({
    required this.icon,
    required this.gradient,
    required this.title,
    required this.tags,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ClayCard(
        radius: AppTheme.radiusXl,
        padding: const EdgeInsets.all(14),
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(4, 4),
                    blurRadius: 10,
                    color: gradient.colors.last.withValues(alpha: 0.3),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.body(size: 15).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    children: [for (final t in tags) _Tag(t)],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 22,
              color: AppTheme.muted,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tag pill ───
class _Tag extends StatelessWidget {
  final String text;
  const _Tag(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: AppTheme.label(size: 11, color: AppTheme.accent),
      ),
    );
  }
}
