import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/app/app_routes.dart';

class PriorityModelListWidget extends StatelessWidget {
  final List<PriorityModel> models;

  const PriorityModelListWidget({
    super.key,
    this.models = const [
      PriorityModel(name: '板块运动', desc: '当前L1 -- 解决后预计 +5 分', rankColor: AppTheme.accent),
      PriorityModel(name: '库仑力平衡', desc: '当前L2 -- 解决后预计 +3 分', rankColor: Color(0xFF8E8E93)),
      PriorityModel(name: '牛顿第二定律应用', desc: '当前L3 -- 不稳定 -- 稳定后预计 +2 分', rankColor: Color(0xFF636366)),
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('优先训练模型', style: AppTheme.heading(size: 18)),
          const SizedBox(height: 12),
          for (int i = 0; i < models.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _item(context, i + 1, models[i]),
          ],
        ],
      ),
    );
  }

  Widget _item(BuildContext context, int rank, PriorityModel model) {
    // Gradient colors per rank
    final gradients = [AppTheme.gradientPrimary, AppTheme.gradientBlue, AppTheme.gradientGreen];
    final gradient = gradients[(rank - 1) % gradients.length];
    final shadowColor = [
      AppTheme.accent.withValues(alpha: 0.25),
      AppTheme.tertiary.withValues(alpha: 0.25),
      AppTheme.success.withValues(alpha: 0.25),
    ][(rank - 1) % 3];

    return ClayCard(
      onTap: () => context.push(AppRoutes.modelDetail),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Gradient rank orb
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(11),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$rank',
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  model.name,
                  style: AppTheme.body(size: 15, weight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(model.desc, style: AppTheme.label(size: 12)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, size: 18, color: AppTheme.muted),
        ],
      ),
    );
  }
}

class PriorityModel {
  final String name;
  final String desc;
  final Color rankColor;

  const PriorityModel({
    required this.name,
    required this.desc,
    required this.rankColor,
  });
}