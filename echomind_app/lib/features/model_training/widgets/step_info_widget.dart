import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';

class StepInfoWidget extends StatelessWidget {
  final int currentStep;
  final String? stepStatus;

  const StepInfoWidget({
    super.key,
    required this.currentStep,
    this.stepStatus,
  });

  static const _titles = [
    '识别训练',
    '决策训练',
    '列式训练',
    '陷阱辨析',
    '完整求解',
    '变式训练',
  ];

  static const _descriptions = [
    '先识别题目结构，确定主导模型与变量关系。',
    '从可用规律中筛选最优解题路径。',
    '将物理关系转化为可计算表达式。',
    '定位常见误区并完成反例辨析。',
    '按完整流程求解并检验结果合理性。',
    '更换场景和参数，强化迁移能力。',
  ];

  @override
  Widget build(BuildContext context) {
    final index = (currentStep - 1).clamp(0, _titles.length - 1);
    final isCompleted = stepStatus == 'completed';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.shadowClayPressed,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'STEP $currentStep / 6',
                style: AppTheme.label(size: 11, color: AppTheme.accent),
              ),
              if (isCompleted) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Text(
                    '本步已完成',
                    style: AppTheme.label(size: 10, color: AppTheme.success),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(_titles[index],
              style: AppTheme.heading(size: 20, weight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(
            _descriptions[index],
            style: AppTheme.body(
                size: 13, weight: FontWeight.w600, color: AppTheme.muted),
          ),
        ],
      ),
    );
  }
}
