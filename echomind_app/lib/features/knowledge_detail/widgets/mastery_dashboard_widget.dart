import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/app/app_routes.dart';
import 'package:echomind_app/providers/knowledge_detail_provider.dart';
import 'package:echomind_app/shared/utils/mastery_utils.dart';

class MasteryDashboardWidget extends ConsumerWidget {
  final String kpId;
  const MasteryDashboardWidget({super.key, required this.kpId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(knowledgeDetailProvider(kpId));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: detail.when(
        loading: () => const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())),
        error: (_, __) => _buildCard(context, level: 2, value: 0.4, errorCount: 3, correctCount: 3),
        data: (d) => _buildCard(context, level: d.masteryLevel ?? 0, value: d.masteryValue ?? 0, errorCount: d.errorCount, correctCount: d.correctCount),
      ),
    );
  }

  Widget _buildCard(BuildContext context, {required int level, required double value, required int errorCount, required int correctCount}) {
    final info = MasteryUtils.levelInfo(level);
    final total = errorCount + correctCount;
    final rate = total > 0 ? '${(correctCount * 100 / total).round()}%' : '-';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('掌握度', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: info.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
              child: Text('L$level', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: info.color)),
            ),
            const SizedBox(width: 8),
            Text(info.label, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          ]),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: value.clamp(0, 1), minHeight: 8, backgroundColor: const Color(0xFFE5E5EA), valueColor: AlwaysStoppedAnimation(info.color)),
          ),
          const SizedBox(height: 12),
          Row(children: [
            _Stat('学习次数', '$total'),
            _Stat('检测正确率', rate),
            _Stat('错题数', '$errorCount'),
          ]),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity, height: 40,
            child: ElevatedButton(
              onPressed: () => context.push('${AppRoutes.knowledgeLearning}?kpId=$kpId'),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)), elevation: 0),
              child: const Text('开始学习', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Column(children: [
      Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
    ]));
  }
}
