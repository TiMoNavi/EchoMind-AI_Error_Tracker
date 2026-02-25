import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';

class ExamAnalysisWidget extends StatelessWidget {
  final String attitude;
  final String scoreTag;
  final List<String> highFreqConcepts;
  final List<String> weakModels;
  final List<String> weakModelOutline;

  const ExamAnalysisWidget({
    super.key,
    this.attitude = 'MUST · 必须拿满',
    this.scoreTag = '满分 3分',
    this.highFreqConcepts = const ['牛顿第二定律', '板块运动', '摩擦力'],
    this.weakModels = const ['板块运动 L1'],
    this.weakModelOutline = const ['牛顿第二定律应用 L3'],
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClayCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _attitudeBadge(attitude),
                _grayTag(scoreTag),
              ],
            ),
            const SizedBox(height: 14),
            Text('高频考点', style: AppTheme.label(size: 12)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final c in highFreqConcepts) _blueTag(c),
              ],
            ),
            const SizedBox(height: 14),
            Text('薄弱模型', style: AppTheme.label(size: 12)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final m in weakModels) _darkTag(m),
                for (final m in weakModelOutline) _outlineTag(m),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _attitudeBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.danger,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Text(text, style: AppTheme.label(size: 12, color: Colors.white)),
    );
  }

  static Widget _grayTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.canvas,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Text(text, style: AppTheme.label(size: 12)),
    );
  }

  static Widget _blueTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Text(text, style: AppTheme.label(size: 12, color: AppTheme.accent)),
    );
  }

  static Widget _darkTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.foreground,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Text(text, style: AppTheme.label(size: 12, color: Colors.white)),
    );
  }

  static Widget _outlineTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.divider),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Text(text, style: AppTheme.label(size: 12)),
    );
  }
}