import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';

class Step1IdentificationTrainingWidget extends StatelessWidget {
  final int stepIndex;
  const Step1IdentificationTrainingWidget({super.key, required this.stepIndex});

  static const _titles = ['识别训练', '决策训练', '列式训练', '陷阱辨析', '完整求解', '变式训练'];
  static const _total = 6;

  @override
  Widget build(BuildContext context) {
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
            Text('STEP ${stepIndex + 1} / $_total -- ${_titles[stepIndex]}',
                style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5)),
            const SizedBox(height: 8),
            Text(_titles[stepIndex],
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            const Text('本步骤只切换顶部 step 模块，下面对话区保持不变',
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}
