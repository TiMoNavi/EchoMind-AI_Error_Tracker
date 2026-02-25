import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/app/app_routes.dart';

class ReviewDashboardWidget extends StatelessWidget {
  final String todayCount;
  final String retentionRate;
  final String totalReviewed;
  final String totalCards;

  const ReviewDashboardWidget({
    super.key,
    this.todayCount = '12',
    this.retentionRate = '87%',
    this.totalReviewed = '156',
    this.totalCards = '48',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          ClayCard(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
            child: Column(
              children: [
                Text('今日待复习', style: AppTheme.label(size: 14)),
                const SizedBox(height: 8),
                Text(
                  todayCount,
                  style: GoogleFonts.nunito(
                    fontSize: 48, fontWeight: FontWeight.w900,
                    color: AppTheme.accent,
                  ),
                ),
                Text('张卡片', style: AppTheme.label(size: 14)),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AppTheme.gradientPrimary,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    boxShadow: AppTheme.shadowClayButton,
                  ),
                  child: ElevatedButton(
                    onPressed: () => context.push(AppRoutes.flashcardReview),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      ),
                      elevation: 0,
                    ),
                    child: Text('开始复习',
                        style: GoogleFonts.nunito(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Stats row
          Row(
            children: [
              Expanded(child: _StatCard(value: retentionRate, label: '本周记住率')),
              const SizedBox(width: 8),
              Expanded(child: _StatCard(value: totalReviewed, label: '累计复习')),
              const SizedBox(width: 8),
              Expanded(child: _StatCard(value: totalCards, label: '总卡片数')),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return ClayCard(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.nunito(
              fontSize: 22, fontWeight: FontWeight.w900,
              color: AppTheme.accent,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTheme.label(size: 12)),
        ],
      ),
    );
  }
}
