import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/app/app_routes.dart';

class RelatedModelsWidget extends StatelessWidget {
  const RelatedModelsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('关联模型', style: AppTheme.heading(size: 18)),
              Text('使用此知识点的模型', style: AppTheme.label(size: 13)),
            ],
          ),
          const SizedBox(height: 10),
          _listGroup(context),
        ],
      ),
    );
  }

  Widget _listGroup(BuildContext context) {
    return Column(
      children: [
        _item(context, '库仑力平衡', 'L2 · 列式卡住',
            const Color(0xFFFF9500)),
        const SizedBox(height: 10),
        _item(context, '电场中的功能关系', 'L0 · 未接触',
            const Color(0xFFAEAEB2)),
      ],
    );
  }

  Widget _item(BuildContext context, String name, String desc, Color dotColor) {
    return ClayCard(
      onTap: () => context.push(AppRoutes.modelDetail),
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
            child: const Icon(Icons.hub_rounded, size: 16, color: Colors.white),
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
}