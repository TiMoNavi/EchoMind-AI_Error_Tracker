import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';

class QuestionContentWidget extends StatelessWidget {
  const QuestionContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClayCard(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.canvas,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '2025天津模拟(一) 第5题',
                style: AppTheme.label(size: 12),
              ),
              const SizedBox(height: 10),
              Text(
                '如图所示, 质量为M的长木板置于光滑水平面上, 质量为m的物块(可视为质点)以速度v₀从左端滑上木板。物块与木板间的动摩擦因数为μ, 木板足够长。求:',
                style: AppTheme.body(size: 15),
              ),
              const SizedBox(height: 6),
              Text(
                '(1) 物块和木板最终速度;\n(2) 物块在木板上滑行的距离。',
                style: AppTheme.body(size: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
