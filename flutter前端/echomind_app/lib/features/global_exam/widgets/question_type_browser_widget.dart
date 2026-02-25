import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/app/app_routes.dart';

class QuestionTypeBrowserWidget extends StatelessWidget {
  const QuestionTypeBrowserWidget({super.key});

  static const _types = [
    (title: '选择题', subtitle: '第1-8题', count: '6/8 掌握', level: 4, icon: Icons.check_circle_outline),
    (title: '实验题', subtitle: '第9-11题', count: '1/3 掌握', level: 2, icon: Icons.science_outlined),
    (title: '计算题', subtitle: '第12-14题', count: '0/3 掌握', level: 0, icon: Icons.calculate_outlined),
  ];

  static const _gradients = [
    LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [Color(0xFF34D399), Color(0xFF10B981)],
    ),
    LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [Color(0xFF38BDF8), Color(0xFF0EA5E9)],
    ),
    LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [Color(0xFFF472B6), Color(0xFFDB2777)],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('按题型浏览', style: AppTheme.heading(size: 18)),
          const SizedBox(height: 12),
          for (var i = 0; i < _types.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _typeCard(context, _types[i], _gradients[i]),
          ],
        ],
      ),
    );
  }

  Widget _typeCard(BuildContext context, dynamic t, LinearGradient grad) {
    return ClayCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      onTap: () => context.push(AppRoutes.questionAggregate),
      child: Row(
        children: [
          // Gradient icon orb
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: grad,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: grad.colors.last.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(t.icon as IconData, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.title as String,
                  style: AppTheme.body(size: 15, weight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  t.subtitle as String,
                  style: AppTheme.label(size: 12),
                ),
              ],
            ),
          ),
          Text(
            t.count as String,
            style: AppTheme.label(size: 12, color: AppTheme.accent),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, size: 18, color: AppTheme.muted),
        ],
      ),
    );
  }
}
