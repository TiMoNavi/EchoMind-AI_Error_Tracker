import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';

class Step1ConceptPresentWidget extends StatelessWidget {
  final int stepIndex;

  const Step1ConceptPresentWidget({super.key, required this.stepIndex});

  static const _total = 5;
  static const _titles = [
    '概念呈现',
    '理解检查',
    '辨析训练',
    '实际应用',
    '概念检测',
  ];
  static const _headlines = [
    '库仑定律的核心内容',
    '检查你对概念的真实理解',
    '库仑定律与万有引力定律辨析',
    '将库仑定律应用到实际问题',
    '概念综合检测',
  ];
  static const _descs = [
    '静电力与两电荷量乘积成正比，与距离平方成反比，方向沿两电荷连线。',
    '通过关键追问，检验你对适用条件和物理意义的掌握程度。',
    '公式形式相似，但作用对象、方向特性和适用条件不同。',
    '结合带电粒子受力情境，训练列式与方向判断能力。',
    '综合检查你对概念、公式和边界条件的掌握情况。',
  ];

  @override
  Widget build(BuildContext context) {
    final safeIndex = stepIndex.clamp(0, _total - 1).toInt();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: ClayCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '第 ${safeIndex + 1} / $_total 步 · ${_titles[safeIndex]}',
              style: AppTheme.label(size: 13, color: AppTheme.accent).copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _headlines[safeIndex],
              style: AppTheme.heading(size: 20, weight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              _descs[safeIndex],
              style: AppTheme.body(size: 14, weight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
