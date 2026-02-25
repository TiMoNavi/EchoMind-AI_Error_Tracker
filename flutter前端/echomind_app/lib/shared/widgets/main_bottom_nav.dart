import 'package:flutter/material.dart';
import 'package:echomind_app/app/app_routes.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:go_router/go_router.dart';

class MainBottomNav extends StatelessWidget {
  final int currentIndex;
  const MainBottomNav({super.key, required this.currentIndex});

  static const _tabs = [
    (icon: Icons.home_outlined, activeIcon: Icons.home, label: '主页', route: AppRoutes.home),
    (icon: Icons.public_outlined, activeIcon: Icons.public, label: '全局', route: AppRoutes.globalKnowledge),
    (icon: Icons.style_outlined, activeIcon: Icons.style, label: '记忆', route: AppRoutes.memory),
    (icon: Icons.people_outline, activeIcon: Icons.people, label: '社区', route: AppRoutes.community),
    (icon: Icons.person_outline, activeIcon: Icons.person, label: '我的', route: AppRoutes.profile),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -6),
            blurRadius: 28,
            color: const Color(0xFFA096B4).withValues(alpha: 0.12),
          ),
          const BoxShadow(
            offset: Offset(0, -1),
            blurRadius: 0,
            color: Color(0x08000000),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 8),
          child: Row(
            children: [
              for (var i = 0; i < _tabs.length; i++)
                Expanded(
                  child: _NavItem(
                    icon: _tabs[i].icon,
                    activeIcon: _tabs[i].activeIcon,
                    label: _tabs[i].label,
                    isActive: i == currentIndex,
                    onTap: () => context.go(_tabs[i].route),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppTheme.accent : AppTheme.muted;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Active indicator dot
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isActive ? 6 : 0,
            height: isActive ? 6 : 0,
            margin: const EdgeInsets.only(bottom: 4),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.accent,
            ),
          ),
          Icon(
            isActive ? activeIcon : icon,
            size: 26,
            color: color,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTheme.label(size: 13, color: color).copyWith(
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
