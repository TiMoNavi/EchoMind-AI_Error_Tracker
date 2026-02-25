import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';

class StepStageNavWidget extends StatelessWidget {
  final int currentStep;
  final ValueChanged<int> onStepChanged;
  const StepStageNavWidget({super.key, required this.currentStep, required this.onStepChanged});

  static const _labels = ['识别\n训练', '决策\n训练', '列式\n训练', '陷阱\n辨析', '完整\n求解', '变式\n训练'];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEFEBF5),
        boxShadow: AppTheme.shadowClayPressed,
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      child: Column(
        children: [
          // Dots + lines row
          Row(
            children: [
              for (int i = 0; i < _labels.length; i++) ...[
                if (i > 0)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: i <= currentStep ? AppTheme.accent : const Color(0xFFE0E0E0),
                    ),
                  ),
                GestureDetector(
                  onTap: () => onStepChanged(i),
                  child: Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i <= currentStep ? AppTheme.accent : const Color(0xFFE0E0E0),
                    ),
                    alignment: Alignment.center,
                    child: Text('${i + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: i <= currentStep ? Colors.white : AppTheme.textSecondary,
                        )),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          // Labels row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (int i = 0; i < _labels.length; i++)
                GestureDetector(
                  onTap: () => onStepChanged(i),
                  child: SizedBox(
                    width: 40,
                    child: Text(_labels[i],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 8,
                          color: i == currentStep ? AppTheme.accent : AppTheme.muted,
                          fontWeight: i == currentStep ? FontWeight.w600 : FontWeight.normal,
                        )),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
