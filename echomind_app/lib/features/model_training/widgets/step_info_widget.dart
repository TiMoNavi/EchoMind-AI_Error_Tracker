import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';

class StepInfoWidget extends StatelessWidget {
  final int currentStep; // 1-6
  final String? stepStatus; // 'in_progress' | 'completed'

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
    '拆分运动过程、确定主语、选择模型',
    '从可用公式中逐个排除，锁定正确公式',
    '理解该模型的标准解题流程',
    '识别该模型的常见错误陷阱',
    '全流程验证，分步骤填空',
    '换场景/数值验证迁移能力',
  ];

  @override
  Widget build(BuildContext context) {
    final idx = (currentStep - 1).clamp(0, 5);
    final isCompleted = stepStatus == 'completed';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'STEP $currentStep / 6 — ${_titles[idx]}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                if (isCompleted) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '已通过',
                      style: TextStyle(
                        fontSize: 9,
                        color: AppTheme.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(_titles[idx],
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(_descriptions[idx],
                style: const TextStyle(
                    fontSize: 13, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}