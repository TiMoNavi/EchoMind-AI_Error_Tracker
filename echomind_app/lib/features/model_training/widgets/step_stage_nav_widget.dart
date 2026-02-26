import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/providers/model_training_provider.dart';

class StepStageNavWidget extends StatelessWidget {
  final int currentStep; // 1-6
  final int entryStep;
  final Map<int, StepResult> stepResults;

  const StepStageNavWidget({
    super.key,
    required this.currentStep,
    this.entryStep = 1,
    this.stepResults = const {},
  });

  static const _labels = [
    '识别\n训练',
    '决策\n训练',
    '列式\n训练',
    '陷阱\n辨析',
    '完整\n求解',
    '变式\n训练',
  ];

  /// 步骤圆点颜色：已通过=success，已失败=danger，当前=primary，未到=灰色
  Color _dotColor(int stepNum) {
    if (stepResults.containsKey(stepNum)) {
      return stepResults[stepNum]!.passed ? AppTheme.success : AppTheme.danger;
    }
    if (stepNum == currentStep) return AppTheme.primary;
    if (stepNum < currentStep) return AppTheme.primary;
    return const Color(0xFFE0E0E0);
  }

  Color _lineColor(int stepNum) {
    return stepNum <= currentStep ? AppTheme.primary : const Color(0xFFE0E0E0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppTheme.divider, width: 0.5)),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      child: Column(
        children: [
          // 圆点 + 连线
          Row(
            children: [
              for (int i = 0; i < _labels.length; i++) ...[
                if (i > 0)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: _lineColor(i + 1),
                    ),
                  ),
                _buildDot(i + 1),
              ],
            ],
          ),
          const SizedBox(height: 6),
          // 标签
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (int i = 0; i < _labels.length; i++)
                SizedBox(
                  width: 40,
                  child: Text(
                    _labels[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 8,
                      color: (i + 1) == currentStep
                          ? AppTheme.primary
                          : AppTheme.textSecondary,
                      fontWeight: (i + 1) == currentStep
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int stepNum) {
    final color = _dotColor(stepNum);
    final isCompleted = stepResults.containsKey(stepNum);

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      alignment: Alignment.center,
      child: isCompleted
          ? Icon(
              stepResults[stepNum]!.passed ? Icons.check : Icons.close,
              size: 14,
              color: Colors.white,
            )
          : Text(
              '$stepNum',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: stepNum <= currentStep
                    ? Colors.white
                    : AppTheme.textSecondary,
              ),
            ),
    );
  }
}