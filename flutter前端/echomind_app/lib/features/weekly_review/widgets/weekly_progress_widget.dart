import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';

class WeeklyProgressWidget extends StatelessWidget {
  const WeeklyProgressWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('本周进展', style: AppTheme.heading(size: 18)),
          const SizedBox(height: 12),
          _listGroup(),
        ],
      ),
    );
  }

  static Widget _listGroup() {
    return Column(
      children: [
        _item('匀变速直线运动', 'L3 --> L4 -- 做对过',
            AppTheme.success, 'UP', true),
        const SizedBox(height: 10),
        _item('牛顿第二定律应用', 'L2 --> L3 -- 执行正确一次',
            AppTheme.warning, 'UP', true),
        const SizedBox(height: 10),
        _item('板块运动', 'L1 --> L1 -- 仍在建模层卡住',
            AppTheme.danger, '--', false),
      ],
    );
  }

  static Widget _item(String name, String desc, Color dotColor,
      String status, bool isUp) {
    return ClayCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 10, height: 10,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: dotColor.withValues(alpha: 0.4),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTheme.body(size: 14, weight: FontWeight.w600)),
                const SizedBox(height: 3),
                Text(desc, style: AppTheme.label(size: 12)),
              ],
            ),
          ),
          Text(status,
              style: AppTheme.label(
                size: 13,
                color: isUp ? AppTheme.accent : AppTheme.muted,
              )),
        ],
      ),
    );
  }
}