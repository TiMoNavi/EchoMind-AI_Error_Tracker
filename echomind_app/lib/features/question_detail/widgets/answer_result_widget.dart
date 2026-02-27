import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/app/app_routes.dart';
import 'package:echomind_app/providers/question_detail_provider.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';

class AnswerResultWidget extends ConsumerWidget {
  final String questionId;

  const AnswerResultWidget({super.key, required this.questionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(questionDetailProvider(questionId));

    final view = detail.when(
      loading: () => const _AnswerView(
        status: '加载中',
        uploadDate: '正在获取作答结果',
        statusTag: '待诊断',
        isPending: true,
        diagnosisHint: 'AI将通过对话定位你的错误在哪一层',
      ),
      error: (_, __) => const _AnswerView(
        status: '错误',
        uploadDate: '暂时无法获取作答结果',
        statusTag: '待诊断',
        isPending: true,
        diagnosisHint: 'AI将通过对话定位你的错误在哪一层',
      ),
      data: (d) {
        final isCorrect = d.isCorrect;
        if (isCorrect == true) {
          return const _AnswerView(
            status: '正确',
            uploadDate: '已完成判定',
            statusTag: '已完成',
            isPending: false,
            diagnosisHint: '可进入 AI 诊断查看解题优势与巩固建议',
          );
        }
        return const _AnswerView(
          status: '错误',
          uploadDate: '已判定，建议尽快完成诊断',
          statusTag: '待诊断',
          isPending: true,
          diagnosisHint: 'AI将通过对话定位你的错误在哪一层',
        );
      },
    );

    final statusColor = view.isPending ? AppTheme.danger : AppTheme.success;
    final statusTagBg = view.isPending ? AppTheme.foreground : AppTheme.success;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          ClayCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    view.isPending ? 'X' : '✓',
                    style: AppTheme.label(size: 14, color: statusColor),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(view.status,
                          style:
                              AppTheme.body(size: 15, weight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(view.uploadDate, style: AppTheme.label(size: 13)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusTagBg,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Text(
                    view.statusTag,
                    style: AppTheme.label(size: 12, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Column(
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
                  onPressed: () => context.push(
                    AppRoutes.aiDiagnosisPath(questionId: questionId),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    ),
                  ),
                  child: Text(
                    '进入诊断',
                    style: AppTheme.body(
                      size: 16,
                      weight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(view.diagnosisHint, style: AppTheme.label(size: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnswerView {
  final String status;
  final String uploadDate;
  final String statusTag;
  final bool isPending;
  final String diagnosisHint;

  const _AnswerView({
    required this.status,
    required this.uploadDate,
    required this.statusTag,
    required this.isPending,
    required this.diagnosisHint,
  });
}
