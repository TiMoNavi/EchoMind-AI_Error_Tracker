import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';
import 'package:go_router/go_router.dart';

class RegisterStrategyPage extends StatefulWidget {
  const RegisterStrategyPage({super.key});

  @override
  State<RegisterStrategyPage> createState() => _RegisterStrategyPageState();
}

class _RegisterStrategyPageState extends State<RegisterStrategyPage> {
  String _selectedExam = '物理';
  final List<String> _exams = ['物理', '数学', '化学'];

  // Mock strategy data — will be replaced by API
  final Map<String, _ExamStrategy> _strategies = {
    '物理': _ExamStrategy(
      totalScore: 110,
      totalTime: 90,
      targetScore: 85,
      sections: [
        _Section('选择题', 8, 48, 25, '每题 3 分钟，不确定先跳过'),
        _Section('实验题', 2, 15, 18, '画图题注意标注，公式写全'),
        _Section('计算题', 4, 47, 40, '先做熟悉的，大题写步骤拿过程分'),
      ],
      tips: [
        '选择题控制在 25 分钟内完成',
        '计算题先审题画受力图再动笔',
        '最后 5 分钟检查涂卡和单位',
      ],
    ),
    '数学': _ExamStrategy(
      totalScore: 150,
      totalTime: 120,
      targetScore: 120,
      sections: [
        _Section('选择题', 8, 40, 30, '前 6 题快速完成，后 2 题可跳过'),
        _Section('填空题', 6, 30, 25, '注意特殊值和边界条件'),
        _Section('解答题', 6, 80, 60, '前 3 题必拿满分，后 3 题拿步骤分'),
      ],
      tips: [
        '选填控制在 55 分钟内',
        '解答题写清每一步推导过程',
        '圆锥曲线题先设后算，注意韦达定理',
      ],
    ),
    '化学': _ExamStrategy(
      totalScore: 100,
      totalTime: 75,
      targetScore: 78,
      sections: [
        _Section('选择题', 7, 42, 20, '有机推断题注意官能团变化'),
        _Section('填空题', 4, 58, 50, '方程式配平、条件、沉淀箭头'),
      ],
      tips: [
        '选择题不超过 20 分钟',
        '实验题注意操作顺序描述',
        '计算题写清摩尔比和单位',
      ],
    ),
  };

  @override
  Widget build(BuildContext context) {
    final strategy = _strategies[_selectedExam]!;
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildExamSelector(),
                    const SizedBox(height: 20),
                    _buildOverviewCard(strategy),
                    const SizedBox(height: 20),
                    _buildSectionsTitle(),
                    const SizedBox(height: 12),
                    ...strategy.sections.map(_buildSectionCard),
                    const SizedBox(height: 24),
                    _buildTipsCard(strategy),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const SizedBox(width: 4),
          Text('卷面策略', style: AppTheme.heading(size: 22)),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildExamSelector() {
    return Wrap(
      spacing: 10,
      children: _exams.map((e) {
        final active = _selectedExam == e;
        return GestureDetector(
          onTap: () => setState(() => _selectedExam = e),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: active ? AppTheme.accent : Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              boxShadow: active
                  ? AppTheme.shadowClayButton
                  : AppTheme.shadowClayCard,
            ),
            child: Text(e, style: AppTheme.label(
              size: 14,
              color: active ? Colors.white : AppTheme.foreground,
            )),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOverviewCard(_ExamStrategy s) {
    return ClayCard(
      radius: AppTheme.radiusCard,
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _overviewItem('${s.totalScore}', '总分', AppTheme.accent),
          _dividerDot(),
          _overviewItem('${s.targetScore}', '目标', AppTheme.success),
          _dividerDot(),
          _overviewItem('${s.totalTime} min', '时长', AppTheme.tertiary),
        ],
      ),
    );
  }

  Widget _overviewItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(value, style: AppTheme.heading(size: 26).copyWith(color: color)),
        const SizedBox(height: 4),
        Text(label, style: AppTheme.label(size: 12)),
      ],
    );
  }

  Widget _dividerDot() {
    return Container(
      width: 4, height: 4,
      decoration: BoxDecoration(
        color: AppTheme.muted.withValues(alpha: 0.3),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildSectionsTitle() {
    return Text('题型分配', style: AppTheme.heading(size: 18));
  }

  Widget _buildSectionCard(_Section section) {
    final ratio = section.score / _strategies[_selectedExam]!.totalScore;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClayCard(
        radius: AppTheme.radiusXl,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(section.name,
                  style: AppTheme.heading(size: 15)),
                const Spacer(),
                _pill('${section.count} 题', AppTheme.accent),
                const SizedBox(width: 8),
                _pill('${section.score} 分', AppTheme.success),
                const SizedBox(width: 8),
                _pill('${section.minutes} min', AppTheme.tertiary),
              ],
            ),
            const SizedBox(height: 12),
            // Score proportion bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 6,
                backgroundColor: AppTheme.canvas,
                valueColor: const AlwaysStoppedAnimation(AppTheme.accent),
              ),
            ),
            const SizedBox(height: 10),
            Text(section.tip,
              style: AppTheme.body(size: 13, color: AppTheme.muted)),
          ],
        ),
      ),
    );
  }

  Widget _pill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Text(text, style: AppTheme.label(size: 11, color: color)),
    );
  }

  Widget _buildTipsCard(_ExamStrategy s) {
    return ClayCard(
      radius: AppTheme.radiusXl,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline_rounded,
                size: 18, color: AppTheme.warning),
              const SizedBox(width: 8),
              Text('答题建议', style: AppTheme.heading(size: 15)),
            ],
          ),
          const SizedBox(height: 12),
          ...s.tips.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 20, height: 20,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text('${e.key + 1}',
                    style: AppTheme.label(size: 11, color: AppTheme.accent)),
                ),
                Expanded(
                  child: Text(e.value,
                    style: AppTheme.body(size: 13)),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _ExamStrategy {
  final int totalScore;
  final int totalTime;
  final int targetScore;
  final List<_Section> sections;
  final List<String> tips;

  const _ExamStrategy({
    required this.totalScore,
    required this.totalTime,
    required this.targetScore,
    required this.sections,
    required this.tips,
  });
}

class _Section {
  final String name;
  final int count;
  final int score;
  final int minutes;
  final String tip;

  const _Section(this.name, this.count, this.score, this.minutes, this.tip);
}
