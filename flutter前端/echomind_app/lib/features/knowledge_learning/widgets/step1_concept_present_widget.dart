import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';

class Step1ConceptPresentWidget extends StatelessWidget {
  final int stepIndex;
  const Step1ConceptPresentWidget({super.key, required this.stepIndex});

  static const _total = 5;
  static const _titles = ['概念呈现', '理解检查', '辨析训练', '实际应用', '概念检测'];
  static const _headlines = [
    '库仑定律的核心内容',
    '你真的理解库仑定律了吗?',
    '库仑定律 vs 万有引力定律',
    '用库仑定律解决实际问题',
    '概念综合检测',
  ];
  static const _descs = [
    '真空中两个静止点电荷之间的相互作用力, 与它们电荷量的乘积成正比, 与距离的平方成反比。',
    '通过几个关键问题, 检验你对库仑定律适用条件和物理意义的理解。',
    '两个公式形式相似, 但适用条件和物理意义完全不同。',
    '将库仑定律应用到具体的物理情境中, 解决带电粒子的受力问题。',
    '综合检测你对库仑定律概念、公式、适用条件的掌握程度。',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: ClayCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'STEP ${stepIndex + 1} / $_total · ${_titles[stepIndex]}',
              style: AppTheme.label(size: 12, color: AppTheme.accent),
            ),
            const SizedBox(height: 10),
            Text(
              _headlines[stepIndex],
              style: AppTheme.heading(size: 18),
            ),
            const SizedBox(height: 6),
            Text(
              _descs[stepIndex],
              style: AppTheme.body(size: 14),
            ),
          ],
        ),
      ),
    );
  }
}
