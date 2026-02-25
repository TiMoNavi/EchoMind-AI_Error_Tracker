import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/app/app_routes.dart';

class MasteryDashboardWidget extends StatelessWidget {
  final int activeLevel;
  final String levelStatusLabel;
  final String previousLevelNote;
  final List<String> tags;

  const MasteryDashboardWidget({
    super.key,
    this.activeLevel = 3,
    this.levelStatusLabel = '使用出错',
    this.previousLevelNote = '曾到达: L4 (能正确使用)',
    this.tags = const ['一级结论', '需理解'],
  });

  static const _levelColors = [
    Color(0xFFAEAEB2), // L0
    Color(0xFFFF3B30), // L1
    Color(0xFFFF9500), // L2
    Color(0xFFFFCC00), // L3
    Color(0xFF34C759), // L4
    Color(0xFF007AFF), // L5
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _mainCard(),
          const SizedBox(height: 12),
          _learnButton(context),
        ],
      ),
    );
  }

  Widget _mainCard() {
    final color = _levelColors[activeLevel];
    return ClayCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Text('当前掌握度', style: AppTheme.label(size: 13)),
          const SizedBox(height: 12),
          _levelCircle(color),
          const SizedBox(height: 12),
          _levelBadges(),
          const SizedBox(height: 8),
          Text(previousLevelNote, style: AppTheme.label(size: 11)),
          const SizedBox(height: 10),
          _tags(),
        ],
      ),
    );
  }

  Widget _levelCircle(Color color) {
    return Container(
      width: 80, height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 4),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('L$activeLevel',
              style: GoogleFonts.nunito(fontSize: 24, fontWeight: FontWeight.w900, color: color)),
          Text(levelStatusLabel, style: AppTheme.label(size: 11)),
        ],
      ),
    );
  }

  Widget _levelBadges() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i <= 5; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          Container(
            width: 32, height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _levelColors[i],
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Opacity(
              opacity: i == activeLevel ? 1.0 : 0.4,
              child: Text('L$i',
                  style: GoogleFonts.nunito(
                    fontSize: 11, fontWeight: FontWeight.w700,
                    color: Colors.white)),
            ),
          ),
        ],
      ],
    );
  }

  Widget _tags() {
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
            child: Text(tags[i],
                style: AppTheme.label(size: 12,
                    color: i == 0 ? Colors.white : AppTheme.muted)),
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
        onPressed: () => context.push(AppRoutes.knowledgeLearning),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
          elevation: 0,
        ),
        child: Text('开始学习',
            style: GoogleFonts.nunito(
                fontSize: 16, fontWeight: FontWeight.w700)),
      ),
    );
  }
}