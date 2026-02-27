import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/providers/strategy_provider.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';

class StrategyHeaderWidget extends ConsumerWidget {
  const StrategyHeaderWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(strategyProvider);
    final strategy = state.strategy;
    if (strategy == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClayCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Icon(Icons.flag_rounded,
                    color: AppTheme.accent, size: 22),
                const SizedBox(width: 8),
                Text('我的目标',
                    style: AppTheme.body(
                        size: 15,
                        weight: FontWeight.w700,
                        color: AppTheme.muted)),
                const Spacer(),
                _buildEditButton(context, ref),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${strategy.targetScore}',
                  style: AppTheme.heading(size: 42, weight: FontWeight.w900)
                      .copyWith(color: AppTheme.accent),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text('/ ${strategy.totalScore} 分',
                      style: AppTheme.label(size: 14)),
                ),
              ],
            ),
            if (strategy.keyMessage != null &&
                strategy.keyMessage!.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_outline,
                        size: 16, color: AppTheme.accent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        strategy.keyMessage!,
                        style: AppTheme.body(size: 14, weight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEditButton(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _showTargetScoreDialog(context, ref),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.accent, width: 1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.edit, size: 14, color: AppTheme.accent),
            const SizedBox(width: 4),
            Text('修改目标分',
                style: AppTheme.label(size: 12, color: AppTheme.accent)),
          ],
        ),
      ),
    );
  }

  void _showTargetScoreDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    final current = ref.read(strategyProvider).strategy;
    if (current != null) {
      controller.text = '${current.targetScore}';
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('修改目标分数'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: '输入新目标分（30-150）',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
            FilledButton(
              onPressed: () async {
                final score = int.tryParse(controller.text);
                if (score == null || score < 30 || score > 150) return;

                Navigator.pop(ctx);
                final changes = await ref
                    .read(strategyProvider.notifier)
                    .updateTargetScore(score);

                if (changes != null && context.mounted) {
                  _showChangesDialog(context, changes);
                }
              },
              child: const Text('确认'),
            ),
          ],
        );
      },
    );
  }

  void _showChangesDialog(BuildContext context, StrategyChanges changes) {
    final hasChanges =
        changes.upgradedToMust.isNotEmpty || changes.downgraded.isNotEmpty;
    if (!hasChanges) return;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('策略变更'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (changes.upgradedToMust.isNotEmpty) ...[
                  Text('升级为必须拿满：',
                      style: AppTheme.body(
                          size: 13,
                          weight: FontWeight.w800,
                          color: AppTheme.danger)),
                  const SizedBox(height: 4),
                  for (final change in changes.upgradedToMust)
                    Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 2),
                      child: Text(
                          '${change.questionRange}: ${change.oldAttitude} -> ${change.newAttitude}'),
                    ),
                  const SizedBox(height: 10),
                ],
                if (changes.downgraded.isNotEmpty) ...[
                  Text('降级项：',
                      style: AppTheme.body(
                          size: 13,
                          weight: FontWeight.w800,
                          color: AppTheme.muted)),
                  const SizedBox(height: 4),
                  for (final change in changes.downgraded)
                    Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 2),
                      child: Text(
                          '${change.questionRange}: ${change.oldAttitude} -> ${change.newAttitude}'),
                    ),
                ],
              ],
            ),
          ),
          actions: [
            FilledButton(
                onPressed: () => Navigator.pop(ctx), child: const Text('知道了')),
          ],
        );
      },
    );
  }
}
