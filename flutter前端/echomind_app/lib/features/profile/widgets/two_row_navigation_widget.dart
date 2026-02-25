import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';

class TwoRowNavigationWidget extends StatelessWidget {
  const TwoRowNavigationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClayCard(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          children: [
            _NavRow(
              icon: Icons.notifications_none_rounded,
              label: '通知设置',
              gradient: AppTheme.gradientPink,
              shadowColor: AppTheme.accentAlt.withValues(alpha: 0.25),
            ),
            _NavRow(
              icon: Icons.info_outline_rounded,
              label: '关于',
              gradient: AppTheme.gradientBlue,
              shadowColor: AppTheme.tertiary.withValues(alpha: 0.25),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final LinearGradient gradient;
  final Color shadowColor;
  final VoidCallback? onTap;
  const _NavRow({required this.icon, required this.label, required this.gradient, required this.shadowColor, this.onTap});

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
              child: Icon(icon, size: 20, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: AppTheme.body(size: 15, weight: FontWeight.w600))),
            const Icon(Icons.chevron_right, size: 18, color: AppTheme.muted),
          ],
        ),
      ),
    );
  }
}
