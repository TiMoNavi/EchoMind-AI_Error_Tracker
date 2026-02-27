import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/providers/upload_history_provider.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';

class HistoryDateScrollWidget extends ConsumerStatefulWidget {
  const HistoryDateScrollWidget({super.key});

  @override
  ConsumerState<HistoryDateScrollWidget> createState() =>
      _HistoryDateScrollWidgetState();
}

class _HistoryDateScrollWidgetState
    extends ConsumerState<HistoryDateScrollWidget> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(uploadHistoryProvider);

    return historyAsync.when(
      loading: () => const SizedBox(height: 36),
      error: (_, __) => const SizedBox(height: 36),
      data: (groups) {
        final dates = groups.map((g) => g.date).toList();
        if (dates.isEmpty) return const SizedBox(height: 36);

        if (_selected >= dates.length) {
          _selected = 0;
        }

        return SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: dates.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final selected = _selected == i;

              return GestureDetector(
                onTap: () => setState(() => _selected = i),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppTheme.accent.withValues(alpha: 0.12)
                        : Colors.white.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    dates[i],
                    style: AppTheme.label(
                        size: 12,
                        color: selected ? AppTheme.accent : AppTheme.muted),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
