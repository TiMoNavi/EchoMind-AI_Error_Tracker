import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/app/app_routes.dart';

class MasteryDashboardWidget extends StatelessWidget {
  final String level;
  final String levelLabel;
  final String levelDesc;
  final String predictedGain;
  final String relatedQuestion;
  final String buttonLabel;
  final List<FunnelLayer> funnelLayers;

  const MasteryDashboardWidget({
    super.key,
    this.level = 'L1',
    this.levelLabel = '建模卡住',
    this.levelDesc = '看到题不确定该用什么方法',
    this.predictedGain = '+5 分',
    this.relatedQuestion = '关联大题第1题 (12分)',
    this.buttonLabel = '开始训练 · 从 Step 1 开始',
    this.funnelLayers = const [
      FunnelLayer(label: '建模层 · 卡住', level: 'L1', widthFrac: 1.0, stuck: true),
      FunnelLayer(label: '列式层 · 未到达', level: 'L2', widthFrac: 0.85, stuck: false),
      FunnelLayer(label: '执行层 · 未到达', level: 'L3', widthFrac: 0.7, stuck: false),
      FunnelLayer(label: '稳定层 · 未到达', level: 'L4-5', widthFrac: 0.55, stuck: false),
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _funnelCard(),
          const SizedBox(height: 12),
          _trainButton(context),
        ],
      ),
    );
  }

  Widget _funnelCard() {
    return ClayCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Text('当前掌握度', style: AppTheme.label(size: 13)),
          const SizedBox(height: 4),
          Text(level,
              style: GoogleFonts.nunito(
                fontSize: 36, fontWeight: FontWeight.w900, color: AppTheme.danger)),
          Text(levelLabel, style: AppTheme.body(size: 15)),
          const SizedBox(height: 2),
          Text(levelDesc, style: AppTheme.label(size: 13)),
          const SizedBox(height: 18),
          _buildFunnelLayers(),
          const SizedBox(height: 14),
          _buildPredictionCard(),
        ],
      ),
    );
  }

  Widget _buildFunnelLayers() {
    return Column(
      children: [
        for (int i = 0; i < funnelLayers.length; i++) ...[
          if (i > 0) const SizedBox(height: 6),
          _funnelBar(funnelLayers[i].label, funnelLayers[i].level,
              funnelLayers[i].widthFrac, funnelLayers[i].stuck),
        ],
      ],
    );
  }

  static Widget _funnelBar(String label, String level, double widthFrac, bool stuck) {
    final barFlex = (widthFrac * 100).toInt();
    return Row(
      children: [
        Expanded(
          flex: barFlex,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              gradient: stuck
                  ? const LinearGradient(colors: [Color(0xFFFF6B6B), Color(0xFFDB2777)])
                  : null,
              color: stuck ? null : AppTheme.canvas,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            alignment: Alignment.center,
            child: Text(label,
                style: AppTheme.label(size: 13,
                    color: stuck ? Colors.white : AppTheme.muted)),
          ),
        ),
        Expanded(flex: 100 - barFlex, child: const SizedBox()),
        const SizedBox(width: 8),
        SizedBox(
          width: 32,
          child: Text(level,
              style: GoogleFonts.nunito(
                  fontSize: 12, fontWeight: FontWeight.w700,
                  color: AppTheme.muted)),
        ),
      ],
    );
  }

  Widget _buildPredictionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: AppTheme.canvas,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Column(
        children: [
          Text('解决后预计', style: AppTheme.label(size: 13)),
          const SizedBox(height: 2),
          Text(predictedGain,
              style: GoogleFonts.nunito(
                  fontSize: 22, fontWeight: FontWeight.w900,
                  color: AppTheme.accent)),
          const SizedBox(height: 2),
          Text(relatedQuestion, style: AppTheme.label(size: 11)),
        ],
      ),
    );
  }

  Widget _trainButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        gradient: AppTheme.gradientPrimary,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.shadowClayButton,
      ),
      child: ElevatedButton(
        onPressed: () => context.push(AppRoutes.modelTraining),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
          elevation: 0,
        ),
        child: Text(buttonLabel,
            style: GoogleFonts.nunito(
                fontSize: 16, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class FunnelLayer {
  final String label;
  final String level;
  final double widthFrac;
  final bool stuck;

  const FunnelLayer({
    required this.label,
    required this.level,
    required this.widthFrac,
    required this.stuck,
  });
}