import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/app/app_routes.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';

class TopFrameWidget extends StatelessWidget {
  const TopFrameWidget({super.key});

  static const _tabs = ['知识点', '模型/方法', '高考卷子'];
  static const _routes = [
    AppRoutes.globalKnowledge,
    null,
    AppRoutes.globalExam
  ];
  static const _activeIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Text(
            '全局知识',
            style: AppTheme.heading(size: 34, weight: FontWeight.w900),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _ClayTabBar(
            tabs: _tabs,
            activeIndex: _activeIndex,
            onTap: (i) {
              final route = _routes[i];
              if (route != null) context.go(route);
            },
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}

class _ClayTabBar extends StatelessWidget {
  final List<String> tabs;
  final int activeIndex;
  final ValueChanged<int> onTap;

  const _ClayTabBar({
    required this.tabs,
    required this.activeIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppTheme.canvas,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        boxShadow: const [
          BoxShadow(
            offset: Offset(4, 4),
            blurRadius: 10,
            color: Color.fromRGBO(160, 150, 180, 0.15),
          ),
          BoxShadow(
            offset: Offset(-3, -3),
            blurRadius: 8,
            color: Color.fromRGBO(255, 255, 255, 0.7),
          ),
        ],
      ),
      child: Row(
        children: [
          for (var i = 0; i < tabs.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(
              child: _ClayTab(
                label: tabs[i],
                isActive: i == activeIndex,
                onTap: () => onTap(i),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ClayTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ClayTab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          boxShadow: isActive
              ? const [
                  BoxShadow(
                    offset: Offset(4, 4),
                    blurRadius: 10,
                    color: Color.fromRGBO(139, 92, 246, 0.12),
                  ),
                  BoxShadow(
                    offset: Offset(-3, -3),
                    blurRadius: 8,
                    color: Color.fromRGBO(255, 255, 255, 0.9),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTheme.label(
            size: 17,
            color: isActive ? AppTheme.accent : AppTheme.muted,
          ).copyWith(
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
