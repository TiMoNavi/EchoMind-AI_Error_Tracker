import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/app/app_routes.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';

class TopFrameWidget extends StatelessWidget {
  const TopFrameWidget({super.key});

  static const _tabs = ['知识点', '模型/方法', '高考卷子'];
  static const _routes = [
    AppRoutes.globalKnowledge,
    AppRoutes.globalModel,
    null
  ];
  static const _activeIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Text('全局考试',
              style: AppTheme.heading(size: 34, weight: FontWeight.w900)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: AppTheme.canvas,
              borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              boxShadow: AppTheme.shadowClayPressed,
            ),
            child: Row(
              children: [
                for (var i = 0; i < _tabs.length; i++) ...[
                  if (i > 0) const SizedBox(width: 4),
                  Expanded(
                    child: GestureDetector(
                      onTap: _routes[i] == null
                          ? null
                          : () => context.go(_routes[i]!),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: i == _activeIndex
                              ? Colors.white
                              : Colors.transparent,
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusLg),
                          boxShadow: i == _activeIndex
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
                          _tabs[i],
                          style: AppTheme.body(
                            size: 14,
                            color: i == _activeIndex
                                ? AppTheme.accent
                                : AppTheme.muted,
                            weight: i == _activeIndex
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ).copyWith(
                            fontWeight: i == _activeIndex
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
