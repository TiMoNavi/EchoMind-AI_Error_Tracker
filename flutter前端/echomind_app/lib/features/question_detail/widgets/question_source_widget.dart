import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';

class QuestionSourceWidget extends StatelessWidget {
  final String source;
  final String questionId;
  final String fullScore;
  final String attitude;

  const QuestionSourceWidget({
    super.key,
    this.source = '2025天津模拟(一)',
    this.questionId = '选择题 第5题',
    this.fullScore = '3 分',
    this.attitude = 'MUST',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClayCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _row('来源卷子', source),
            const SizedBox(height: 10),
            _row('题号', questionId),
            const SizedBox(height: 10),
            _row('满分', fullScore),
            const SizedBox(height: 10),
            _attitudeRow(),
          ],
        ),
      ),
    );
  }

  static Widget _row(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTheme.label(size: 13)),
        Text(value, style: AppTheme.body(size: 13)),
      ],
    );
  }

  Widget _attitudeRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('态度', style: AppTheme.label(size: 13)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppTheme.danger,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
          child: Text(attitude, style: AppTheme.label(size: 11, color: Colors.white)),
        ),
      ],
    );
  }
}