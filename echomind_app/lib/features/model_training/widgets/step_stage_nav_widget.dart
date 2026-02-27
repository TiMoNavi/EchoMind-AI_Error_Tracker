import 'package:flutter/material.dart';
import 'package:echomind_app/providers/model_training_provider.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';

class StepStageNavWidget extends StatelessWidget {
  final int currentStep;
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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.shadowClayPressed,
      ),
      child: Column(
        children: [
          Row(
            children: [
              for (var i = 0; i < _labels.length; i++) ...[
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
          const SizedBox(height: 7),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < _labels.length; i++)
                SizedBox(
                  width: 42,
                  child: Text(
                    _labels[i],
                    textAlign: TextAlign.center,
                    style: AppTheme.label(
                      size: 9,
                      color: (i + 1) == currentStep
                          ? AppTheme.accent
                          : AppTheme.muted,
                    ).copyWith(
                      fontWeight: (i + 1) == currentStep
                          ? FontWeight.w800
                          : FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int step) {
    final color = _dotColor(step);
    final result = stepResults[step];

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      alignment: Alignment.center,
      child: result != null
          ? Icon(
              result.passed ? Icons.check : Icons.close,
              size: 14,
              color: Colors.white,
            )
          : Text(
              '$step',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: step >= entryStep && step <= currentStep
                    ? Colors.white
                    : AppTheme.muted,
              ),
            ),
    );
  }

  Color _dotColor(int step) {
    if (step < entryStep) return const Color(0xFFD9D4E3);

    final result = stepResults[step];
    if (result != null) {
      return result.passed ? AppTheme.success : AppTheme.danger;
    }
    if (step == currentStep) return AppTheme.accent;
    if (step < currentStep) return AppTheme.accentLight;
    return const Color(0xFFD9D4E3);
  }

  Color _lineColor(int step) {
    if (step <= entryStep) return const Color(0xFFD9D4E3);
    return step <= currentStep ? AppTheme.accent : const Color(0xFFD9D4E3);
  }
}
