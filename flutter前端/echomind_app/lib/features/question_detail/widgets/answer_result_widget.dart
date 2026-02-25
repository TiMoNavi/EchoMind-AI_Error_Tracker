import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/app/app_routes.dart';

class AnswerResultWidget extends StatelessWidget {
  final String status;
  final String uploadDate;
  final String statusTag;
  final bool isPending;
  final String diagnosisHint;

  const AnswerResultWidget({
    super.key,
    this.status = '错误',
    this.uploadDate = '2月8日上传',
    this.statusTag = '待诊断',
    this.isPending = true,
    this.diagnosisHint = 'AI将通过对话定位你的错误在哪一层',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _statusCard(),
          const SizedBox(height: 12),
          _diagnosisButton(context),
        ],
      ),
    );
  }

  Widget _statusCard() {
    return ClayCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppTheme.danger.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text('X', style: AppTheme.label(size: 14, color: AppTheme.danger)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(status, style: AppTheme.body(size: 15, weight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(uploadDate, style: AppTheme.label(size: 13)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.foreground,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Text(statusTag, style: AppTheme.label(size: 12, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _diagnosisButton(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            gradient: AppTheme.gradientPrimary,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            boxShadow: AppTheme.shadowClayButton,
          ),
          child: ElevatedButton(
            onPressed: () => context.push(AppRoutes.aiDiagnosis),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              ),
            ),
            child: Text('进入诊断', style: AppTheme.body(size: 16, weight: FontWeight.w700, color: Colors.white)),
          ),
        ),
        const SizedBox(height: 8),
        Text(diagnosisHint, style: AppTheme.label(size: 12)),
      ],
    );
  }
}