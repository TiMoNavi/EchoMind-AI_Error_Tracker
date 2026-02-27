import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/app/app_routes.dart';
import 'package:echomind_app/providers/exam_provider.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';

class QuestionTypeBrowserWidget extends ConsumerWidget {
  const QuestionTypeBrowserWidget({super.key});

  static const _mockTypes = [
    QuestionTypeItem(
        title: '选择题', subtitle: '第1-8题', count: '6/8 掌握', level: 4),
    QuestionTypeItem(
        title: '实验题', subtitle: '第9-11题', count: '1/3 掌握', level: 2),
    QuestionTypeItem(
        title: '计算题', subtitle: '第12-14题', count: '0/3 掌握', level: 0),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typesAsync = ref.watch(questionTypesProvider);
    final types = typesAsync.whenOrNull(data: (d) => d.isNotEmpty ? d : null) ??
        _mockTypes;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('按题型浏览',
              style: AppTheme.heading(size: 18, weight: FontWeight.w900)),
          const SizedBox(height: 12),
          for (var i = 0; i < types.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _buildTypeCard(context, types[i], i),
          ],
        ],
      ),
    );
  }

  Widget _buildTypeCard(
      BuildContext context, QuestionTypeItem type, int index) {
    final gradient = _gradientByIndex(index);

    return ClayCard(
      onTap: () => context.push(AppRoutes.questionAggregate),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: gradient.colors.last.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(_iconByIndex(index), color: Colors.white, size: 21),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(type.title,
                    style: AppTheme.body(size: 15, weight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(type.subtitle, style: AppTheme.label(size: 12)),
              ],
            ),
          ),
          Text(type.count,
              style: AppTheme.label(size: 12, color: AppTheme.accent)),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, size: 18, color: AppTheme.muted),
        ],
      ),
    );
  }

  LinearGradient _gradientByIndex(int index) {
    switch (index % 3) {
      case 0:
        return AppTheme.gradientGreen;
      case 1:
        return AppTheme.gradientBlue;
      default:
        return AppTheme.gradientPink;
    }
  }

  IconData _iconByIndex(int index) {
    switch (index % 3) {
      case 0:
        return Icons.check_circle_outline;
      case 1:
        return Icons.science_outlined;
      default:
        return Icons.calculate_outlined;
    }
  }
}
