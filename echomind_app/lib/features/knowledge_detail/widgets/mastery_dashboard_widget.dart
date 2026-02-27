import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/app/app_routes.dart';
import 'package:echomind_app/providers/knowledge_detail_provider.dart';
import 'package:echomind_app/shared/utils/mastery_utils.dart';

class MasteryDashboardWidget extends ConsumerWidget {
  final String kpId;

  const MasteryDashboardWidget({super.key, required this.kpId});

  static const _levelColors = [
    Color(0xFFAEAEB2), // L0
    Color(0xFFFF3B30), // L1
    Color(0xFFFF9500), // L2
    Color(0xFFFFCC00), // L3
    Color(0xFF34C759), // L4
    Color(0xFF007AFF), // L5
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(knowledgeDetailProvider(kpId));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: detail.when(
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          ),
        ),
        error: (_, __) => _buildDashboard(
          context,
          level: 2,
          value: 0.4,
          errorCount: 3,
          correctCount: 3,
          conclusionLevel: 2,
        ),
        data: (d) => _buildDashboard(
          context,
          level: d.masteryLevel ?? 0,
          value: d.masteryValue ?? 0,
          errorCount: d.errorCount,
          correctCount: d.correctCount,
          conclusionLevel: d.conclusionLevel,
        ),
      ),
    );
  }

  Widget _buildDashboard(
    BuildContext context, {
    required int level,
    required double value,
    required int errorCount,
    required int correctCount,
    required int conclusionLevel,
  }) {
    final activeLevel = level.clamp(0, 5).toInt();
    final total = errorCount + correctCount;
    final rate = total > 0 ? '${(correctCount * 100 / total).round()}%' : '--';
    final levelInfo = MasteryUtils.levelInfo(activeLevel);
    final previousLevelNote = total > 0 ? '正确率 $rate · 练习次数 $total' : '暂无学习记录';

    final tags = <String>[
      '结论 L$conclusionLevel',
      errorCount > correctCount ? '需巩固' : '可进阶',
    ];

    return Column(
      children: [
        ClayCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Text(
                '当前掌握度',
                style: AppTheme.label(size: 14).copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              _levelCircle(
                color: _levelColors[activeLevel],
                level: activeLevel,
                statusLabel: levelInfo.label,
              ),
              const SizedBox(height: 12),
              _levelBadges(activeLevel),
              const SizedBox(height: 8),
              Text(previousLevelNote, style: AppTheme.label(size: 12)),
              const SizedBox(height: 10),
              _tags(tags),
              const SizedBox(height: 10),
              Text(
                '掌握度 ${(value.clamp(0, 1) * 100).round()}%',
                style: AppTheme.label(size: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _learnButton(context),
      ],
    );
  }

  Widget _levelCircle({
    required Color color,
    required int level,
    required String statusLabel,
  }) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 4),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'L$level',
            style: GoogleFonts.nunito(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          Text(statusLabel, style: AppTheme.label(size: 11)),
        ],
      ),
    );
  }

  Widget _levelBadges(int activeLevel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i <= 5; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          Container(
            width: 32,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _levelColors[i],
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Opacity(
              opacity: i == activeLevel ? 1.0 : 0.4,
              child: Text(
                'L$i',
                style: GoogleFonts.nunito(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _tags(List<String> tags) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < tags.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: i == 0 ? AppTheme.accent : AppTheme.canvas,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Text(
              tags[i],
              style: AppTheme.label(
                size: 12,
                color: i == 0 ? Colors.white : AppTheme.muted,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _learnButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        gradient: AppTheme.gradientPrimary,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.shadowClayButton,
      ),
      child: ElevatedButton(
        onPressed: () =>
            context.push('${AppRoutes.knowledgeLearning}?kpId=$kpId'),
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
          '开始学习',
          style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
