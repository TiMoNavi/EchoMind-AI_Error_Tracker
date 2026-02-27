import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/app/app_routes.dart';
import 'package:echomind_app/providers/dashboard_provider.dart';

class ReviewDashboardWidget extends ConsumerWidget {
  const ReviewDashboardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(dashboardProvider);
    return asyncData.when(
      loading: () => const SizedBox(
        height: 160,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => _buildContent(
        context: context,
        todayCount: '12',
        retentionRate: '87%',
        totalReviewed: '156',
        totalCards: '48',
      ),
      data: (data) => _buildContent(
        context: context,
        todayCount:
            '${(data.totalQuestions - data.masteryCount).clamp(0, 99999)}',
        retentionRate: '${(data.calculationAccuracy * 100).round()}%',
        totalReviewed: '${data.masteryCount + data.errorCount}',
        totalCards: '${data.totalQuestions}',
      ),
    );
  }

  Widget _buildContent({
    required BuildContext context,
    required String todayCount,
    required String retentionRate,
    required String totalReviewed,
    required String totalCards,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          ClayCard(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
            child: Column(
              children: [
                Text(
                  '今日待复习',
                  style: AppTheme.label(size: 14).copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  todayCount,
                  style: GoogleFonts.nunito(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
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
                    child: Text(
                      '开始复习',
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(value: retentionRate, label: '本周记住率'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatCard(value: totalReviewed, label: '累计复习'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatCard(value: totalCards, label: '总卡片数'),
              ),
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
              fontSize: 22,
              fontWeight: FontWeight.w900,
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
