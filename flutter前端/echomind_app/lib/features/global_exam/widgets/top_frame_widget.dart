import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/app/app_routes.dart';

class TopFrameWidget extends StatelessWidget {
  const TopFrameWidget({super.key});

  static const _tabs = ['知识点', '模型/方法', '高考卷子'];
  static const _routes = [AppRoutes.globalKnowledge, AppRoutes.globalModel, null];
  static const _activeIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Text('全局知识', style: AppTheme.heading(size: 28)),
        ),
        // Clay recessed tab bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: const Color(0xFFEFEBF5),
              borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              boxShadow: AppTheme.shadowClayPressed,
            ),
            child: Row(
              children: [
                for (var i = 0; i < _tabs.length; i++) ...[
                  if (i > 0) const SizedBox(width: 4),
                  Expanded(child: _tabItem(context, i)),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _tabItem(BuildContext context, int i) {
    final active = i == _activeIndex;
    return GestureDetector(
      onTap: _routes[i] != null ? () => context.go(_routes[i]!) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                  const BoxShadow(
                    color: Color.fromRGBO(255, 255, 255, 0.9),
                    offset: Offset(-2, -2),
                    blurRadius: 6,
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          _tabs[i],
          style: AppTheme.body(
            size: 14,
            weight: active ? FontWeight.w700 : FontWeight.w500,
            color: active ? AppTheme.accent : AppTheme.muted,
          ),
        ),
      ),
    );
  }
}
