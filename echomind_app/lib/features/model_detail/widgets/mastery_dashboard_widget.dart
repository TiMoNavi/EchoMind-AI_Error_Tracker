import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/app/app_routes.dart';
import 'package:echomind_app/models/model_item.dart';
import 'package:echomind_app/providers/model_detail_provider.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/utils/mastery_utils.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';

class MasteryDashboardWidget extends ConsumerWidget {
  final String modelId;

  const MasteryDashboardWidget({super.key, required this.modelId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(modelDetailProvider(modelId));

    final data = detail.when(
      loading: _DashboardData.fallback,
      error: (_, __) => _DashboardData.fallback(),
      data: _DashboardData.fromDetail,
    );

    final info = MasteryUtils.levelInfo(data.level);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          ClayCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Text('当前掌握度', style: AppTheme.label(size: 13)),
                const SizedBox(height: 4),
                Text(
                  'L${data.level}',
                  style: AppTheme.heading(size: 36, weight: FontWeight.w900)
                      .copyWith(color: info.color),
                ),
                Text(
                  data.levelLabel,
                  style: AppTheme.body(size: 15, weight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(data.levelDesc, style: AppTheme.label(size: 13)),
                const SizedBox(height: 18),
                Column(
                  children: [
                    for (var i = 0; i < data.funnelLayers.length; i++) ...[
                      if (i > 0) const SizedBox(height: 6),
                      _funnelBar(data.funnelLayers[i]),
                    ],
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.canvas,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: Column(
                    children: [
                      Text('解决后预计', style: AppTheme.label(size: 13)),
                      const SizedBox(height: 2),
                      Text(
                        data.predictedGain,
                        style:
                            AppTheme.heading(size: 22, weight: FontWeight.w900)
                                .copyWith(color: AppTheme.accent),
                      ),
                      const SizedBox(height: 2),
                      Text(data.relatedQuestion,
                          style: AppTheme.label(size: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppTheme.gradientPrimary,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              boxShadow: AppTheme.shadowClayButton,
            ),
            child: ElevatedButton(
              onPressed: () => context.push(
                AppRoutes.modelTrainingPath(
                  modelId: modelId,
                  source: 'self_study',
                ),
              ),
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
                data.buttonLabel,
                style: AppTheme.body(
                  size: 16,
                  weight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _funnelBar(_FunnelLayer layer) {
    final barFlex = (layer.widthFrac * 100).round().clamp(1, 100);

    return Row(
      children: [
        Expanded(
          flex: barFlex,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              gradient: layer.stuck
                  ? const LinearGradient(
                      colors: [Color(0xFFFF6B6B), Color(0xFFDB2777)],
                    )
                  : null,
              color: layer.stuck ? null : AppTheme.canvas,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            alignment: Alignment.center,
            child: Text(
              layer.label,
              style: AppTheme.label(
                size: 13,
                color: layer.stuck ? Colors.white : AppTheme.muted,
              ),
            ),
          ),
        ),
        Expanded(flex: 100 - barFlex, child: const SizedBox()),
        const SizedBox(width: 8),
        SizedBox(
          width: 36,
          child: Text(
            layer.levelText,
            style: AppTheme.label(size: 12, color: AppTheme.muted),
          ),
        ),
      ],
    );
  }
}

class _DashboardData {
  final int level;
  final String levelLabel;
  final String levelDesc;
  final String predictedGain;
  final String relatedQuestion;
  final String buttonLabel;
  final List<_FunnelLayer> funnelLayers;

  const _DashboardData({
    required this.level,
    required this.levelLabel,
    required this.levelDesc,
    required this.predictedGain,
    required this.relatedQuestion,
    required this.buttonLabel,
    required this.funnelLayers,
  });

  factory _DashboardData.fromDetail(ModelDetail detail) {
    final level = (detail.masteryLevel ?? 1).clamp(0, 5);
    final wrong = detail.errorCount;
    final predictedGain = '+${(wrong + 3).clamp(2, 12)} 分';

    final chapter = detail.chapter.trim();
    final section = detail.section.trim();
    final related = chapter.isEmpty && section.isEmpty
        ? '关联大题第1题 (12分)'
        : '${chapter.isEmpty ? '关联章节' : chapter} · ${section.isEmpty ? '关键模型' : section}';

    return _DashboardData(
      level: level,
      levelLabel: _levelLabel(level),
      levelDesc: _levelDesc(level),
      predictedGain: predictedGain,
      relatedQuestion: related,
      buttonLabel: '开始训练 · 从 Step 1 开始',
      funnelLayers: _buildFunnelLayers(level),
    );
  }

  factory _DashboardData.fallback() => _DashboardData(
        level: 1,
        levelLabel: '建模卡住',
        levelDesc: '看到题不确定该用什么方法',
        predictedGain: '+5 分',
        relatedQuestion: '关联大题第1题 (12分)',
        buttonLabel: '开始训练 · 从 Step 1 开始',
        funnelLayers: _buildFunnelLayers(1),
      );

  static String _levelLabel(int level) => switch (level) {
        0 => '未学习',
        1 => '建模卡住',
        2 => '列式不稳',
        3 => '执行波动',
        4 => '稳定提升',
        _ => '熟练掌握',
      };

  static String _levelDesc(int level) => switch (level) {
        0 => '尚未开始该模型训练',
        1 => '看到题不确定该用什么方法',
        2 => '会选模型但列式容易出错',
        3 => '能做出来但过程不稳定',
        4 => '大多数题目可稳定完成',
        _ => '可迁移到相近模型与变式',
      };

  static List<_FunnelLayer> _buildFunnelLayers(int level) {
    final stuckIndex = switch (level) {
      <= 1 => 0,
      2 => 1,
      3 => 2,
      _ => 3,
    };

    const widths = [1.0, 0.85, 0.7, 0.55];
    const layerNames = ['建模层', '列式层', '执行层', '稳定层'];
    const levelTexts = ['L1', 'L2', 'L3', 'L4-5'];

    return List<_FunnelLayer>.generate(4, (i) {
      final suffix = i < stuckIndex ? '已通过' : (i == stuckIndex ? '卡住' : '未到达');
      return _FunnelLayer(
        label: '${layerNames[i]} · $suffix',
        levelText: levelTexts[i],
        widthFrac: widths[i],
        stuck: i == stuckIndex,
      );
    });
  }
}

class _FunnelLayer {
  final String label;
  final String levelText;
  final double widthFrac;
  final bool stuck;

  const _FunnelLayer({
    required this.label,
    required this.levelText,
    required this.widthFrac,
    required this.stuck,
  });
}
