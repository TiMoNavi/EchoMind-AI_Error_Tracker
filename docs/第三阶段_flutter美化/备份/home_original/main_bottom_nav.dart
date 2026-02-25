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
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (i) => context.go(_tabs[i].route),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppTheme.primary,
      unselectedItemColor: AppTheme.textSecondary,
      backgroundColor: AppTheme.surface,
      selectedFontSize: 11,
      unselectedFontSize: 11,
      items: [
        for (final t in _tabs)
          BottomNavigationBarItem(
            icon: Icon(t.icon),
            activeIcon: Icon(t.activeIcon),
            label: t.label,
          ),
      ],
    );
  }
}
