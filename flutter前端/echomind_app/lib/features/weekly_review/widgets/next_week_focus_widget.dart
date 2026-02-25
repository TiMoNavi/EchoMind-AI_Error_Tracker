import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';

class NextWeekFocusWidget extends StatelessWidget {
  const NextWeekFocusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('下周重点', style: AppTheme.heading(size: 18)),
          const SizedBox(height: 12),
          _card(),
        ],
      ),
    );
  }

  static Widget _card() {
    return ClayCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _line('1.', '板块运动 -- 完成 Step 1-3 训练'),
          const SizedBox(height: 10),
          _line('2.', '摩擦力知识点 -- 补强到 L3 以上'),
          const SizedBox(height: 10),
          _line('3.', '完成 3 张待诊断题目'),
        ],
      ),
    );
  }

  static Widget _line(String num, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(num, style: AppTheme.body(size: 14, weight: FontWeight.w700, color: AppTheme.accent)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text, style: AppTheme.body(size: 14)),
        ),
      ],
    );
  }
}