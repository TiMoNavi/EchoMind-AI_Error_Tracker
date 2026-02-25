import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/app/app_routes.dart';

class QuestionRelationsWidget extends StatelessWidget {
  const QuestionRelationsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClayCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('归属模型', style: AppTheme.label(size: 12)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: [
                _blueTag(context, '板块运动', AppRoutes.modelDetail),
              ],
            ),
            const SizedBox(height: 14),
            Text('关联知识点', style: AppTheme.label(size: 12)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _grayTag(context, '牛顿第二定律', AppRoutes.knowledgeDetail),
                _grayTag(context, '摩擦力', AppRoutes.knowledgeDetail),
                _grayTag(context, '动量守恒', AppRoutes.knowledgeDetail),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _blueTag(BuildContext context, String text, String route) {
    return GestureDetector(
      onTap: () => context.push(route),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppTheme.accent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
        child: Text(text, style: AppTheme.label(size: 12, color: AppTheme.accent)),
      ),
    );
  }

  Widget _grayTag(BuildContext context, String text, String route) {
    return GestureDetector(
      onTap: () => context.push(route),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppTheme.canvas,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
        child: Text(text, style: AppTheme.label(size: 12)),
      ),
    );
  }
}