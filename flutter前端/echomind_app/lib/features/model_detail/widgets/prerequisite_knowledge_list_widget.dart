import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/app/app_routes.dart';

class PrerequisiteKnowledgeListWidget extends StatelessWidget {
  const PrerequisiteKnowledgeListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('前置知识点', style: AppTheme.heading(size: 18)),
          const SizedBox(height: 10),
          _listGroup(context),
          const SizedBox(height: 10),
          _suggestionTip(),
        ],
      ),
    );
  }

  Widget _listGroup(BuildContext context) {
    return Column(
      children: [
        _item(context, '牛顿第二定律', 'L3 · 使用出错',
            const Color(0xFFFF9500)),
        const SizedBox(height: 10),
        _item(context, '摩擦力分析', 'L2 · 理解不深',
            AppTheme.danger),
      ],
    );
  }

  Widget _item(BuildContext ctx, String name, String desc, Color dotColor) {
    return ClayCard(
      onTap: () => ctx.push(AppRoutes.knowledgeDetail),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [dotColor.withValues(alpha: 0.8), dotColor],
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              boxShadow: [
                BoxShadow(
                  color: dotColor.withValues(alpha: 0.3),
                  blurRadius: 8, offset: const Offset(0, 3)),
              ],
            ),
            child: const Icon(Icons.menu_book_rounded, size: 16, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTheme.body(size: 14, weight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(desc, style: AppTheme.label(size: 12)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, size: 18, color: AppTheme.muted),
        ],
      ),
    );
  }

  static Widget _suggestionTip() {
    return ClayCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              gradient: AppTheme.gradientBlue,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: const Icon(Icons.lightbulb_outline, size: 14, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '建议先学习 "摩擦力分析" (当前L2), 掌握后训练效果更好',
              style: AppTheme.label(size: 13, color: const Color(0xFF1D4ED8)),
            ),
          ),
        ],
      ),
    );
  }
}