import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/app/app_routes.dart';

class ThreeRowNavigationWidget extends StatelessWidget {
  final String uploadCount;

  const ThreeRowNavigationWidget({
    super.key,
    this.uploadCount = '32条',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClayCard(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          children: [
            _NavRow(
              icon: 'UL', label: '上传历史',
              gradient: AppTheme.gradientPrimary,
              shadowColor: AppTheme.accent.withValues(alpha: 0.25),
              trailing: uploadCount,
              onTap: () => context.push(AppRoutes.uploadHistory),
            ),
            _NavRow(
              icon: 'WK', label: '周复盘',
              gradient: AppTheme.gradientBlue,
              shadowColor: AppTheme.tertiary.withValues(alpha: 0.25),
              onTap: () => context.push(AppRoutes.weeklyReview),
            ),
            _NavRow(
              icon: 'EP', label: '卷面策略',
              gradient: AppTheme.gradientGreen,
              shadowColor: AppTheme.success.withValues(alpha: 0.25),
              onTap: () => context.push(AppRoutes.registerStrategy),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  final String icon, label;
  final LinearGradient gradient;
  final Color shadowColor;
  final String? trailing;
  final VoidCallback? onTap;
  const _NavRow({required this.icon, required this.label, required this.gradient, required this.shadowColor, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(11),
                boxShadow: [
                  BoxShadow(color: shadowColor, blurRadius: 8, offset: const Offset(0, 3)),
                ],
              ),
              alignment: Alignment.center,
              child: Text(icon, style: AppTheme.label(size: 12, color: Colors.white)),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: AppTheme.body(size: 15, weight: FontWeight.w600))),
            if (trailing != null) ...[
              Text(trailing!, style: AppTheme.label(size: 13)),
              const SizedBox(width: 4),
            ],
            const Icon(Icons.chevron_right, size: 18, color: AppTheme.muted),
          ],
        ),
      ),
    );
  }
}
