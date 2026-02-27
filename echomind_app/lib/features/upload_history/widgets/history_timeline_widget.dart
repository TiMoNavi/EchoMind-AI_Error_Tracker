import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/providers/upload_history_provider.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';

class HistoryTimelineWidget extends ConsumerWidget {
  const HistoryTimelineWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(uploadHistoryProvider);

    return historyAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (groups) {
        if (groups.isEmpty) {
          return const SizedBox.shrink();
        }

        final total = groups.fold<int>(0, (sum, g) => sum + g.questions.length);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ClayCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                _buildStat('记录天数', '${groups.length}'),
                _buildStat('累计题量', '$total'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStat(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: AppTheme.heading(size: 24, weight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(label, style: AppTheme.label(size: 11)),
        ],
      ),
    );
  }
}
