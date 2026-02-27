import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/providers/weekly_review_provider.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';

class NextWeekFocusWidget extends ConsumerWidget {
  const NextWeekFocusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(weeklyReviewProvider);

    return asyncData.when(
      loading: () => const SizedBox(
        height: 80,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => _buildContent(_fallbackItems),
      data: (data) {
        final items =
            data.focusItems.isEmpty ? _fallbackItems : data.focusItems;
        return _buildContent(items);
      },
    );
  }

  Widget _buildContent(List<String> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('下周重点',
              style: AppTheme.heading(size: 18, weight: FontWeight.w900)),
          const SizedBox(height: 12),
          ClayCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${i + 1}.',
                        style: AppTheme.body(
                            size: 14,
                            weight: FontWeight.w800,
                            color: AppTheme.accent),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(items[i],
                            style: AppTheme.body(
                                size: 14, weight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  if (i < items.length - 1) const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static const _fallbackItems = [
    '板块运动 -- 完成 Step 1-3 训练',
    '摩擦力知识点 -- 补强到 L3 以上',
    '完成 3 张待诊断题目',
  ];
}
