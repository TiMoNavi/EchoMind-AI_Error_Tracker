import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/providers/strategy_provider.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';

class ScoreCompareWidget extends ConsumerWidget {
  const ScoreCompareWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(strategyProvider);
    final strategy = state.strategy;
    if (strategy == null) return const SizedBox.shrink();

    final hasLower =
        strategy.vsLower != null && strategy.vsLower!.trim().isNotEmpty;
    final hasHigher =
        strategy.vsHigher != null && strategy.vsHigher!.trim().isNotEmpty;
    if (!hasLower && !hasHigher) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClayCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('分档对比',
                style: AppTheme.heading(size: 18, weight: FontWeight.w900)),
            const SizedBox(height: 10),
            if (hasLower)
              _buildCompareItem(
                icon: Icons.arrow_downward_rounded,
                color: AppTheme.success,
                label: '比低档多要求',
                text: strategy.vsLower!,
              ),
            if (hasLower && hasHigher) const SizedBox(height: 8),
            if (hasHigher)
              _buildCompareItem(
                icon: Icons.arrow_upward_rounded,
                color: AppTheme.warning,
                label: '比高档可放宽',
                text: strategy.vsHigher!,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompareItem({
    required IconData icon,
    required Color color,
    required String label,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: AppTheme.body(
                      size: 12, weight: FontWeight.w800, color: color)),
              const SizedBox(height: 2),
              Text(text,
                  style: AppTheme.body(size: 13, weight: FontWeight.w700)),
            ],
          ),
        ),
      ],
    );
  }
}
