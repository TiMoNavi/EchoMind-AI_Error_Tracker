import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/providers/strategy_provider.dart';

class StrategyHeaderWidget extends ConsumerWidget {
  const StrategyHeaderWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(strategyProvider);
    final strategy = state.strategy;
    if (strategy == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 目标分数
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Icon(Icons.flag_rounded,
                    color: AppTheme.primary, size: 22),
                const SizedBox(width: 8),
                const Text('我的目标',
                    style: TextStyle(fontSize: 15, color: AppTheme.textSecondary)),
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
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    ' / ${strategy.totalScore}分',
                    style: const TextStyle(
                        fontSize: 16, color: AppTheme.textSecondary),
                  ),
                ),
              ],
            ),
            // 关键话术
            if (strategy.keyMessage != null &&
                strategy.keyMessage!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('💬 ', style: TextStyle(fontSize: 16)),
                    Expanded(
                      child: Text(
                        strategy.keyMessage!,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: AppTheme.textPrimary,
                        ),
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
          border: Border.all(color: AppTheme.primary, width: 1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit, size: 14, color: AppTheme.primary),
            SizedBox(width: 4),
            Text('修改目标分',
                style: TextStyle(fontSize: 12, color: AppTheme.primary)),
          ],
        ),
      ),
    );
  }

  void _showTargetScoreDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    final state = ref.read(strategyProvider);
    if (state.strategy != null) {
      controller.text = '${state.strategy!.targetScore}';
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
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
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
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
      ),
    );
  }

  void _showChangesDialog(BuildContext context, StrategyChanges changes) {
    final hasChanges =
        changes.upgradedToMust.isNotEmpty || changes.downgraded.isNotEmpty;
    if (!hasChanges) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('策略变更'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (changes.upgradedToMust.isNotEmpty) ...[
                const Text('升级为必须拿满：',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: Color(0xFFE53935))),
                const SizedBox(height: 4),
                ...changes.upgradedToMust.map((c) => Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 2),
                      child: Text('${c.questionRange}: ${c.oldAttitude} → ${c.newAttitude}'),
                    )),
                const SizedBox(height: 12),
              ],
              if (changes.downgraded.isNotEmpty) ...[
                const Text('降级：',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary)),
                const SizedBox(height: 4),
                ...changes.downgraded.map((c) => Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 2),
                      child: Text('${c.questionRange}: ${c.oldAttitude} → ${c.newAttitude}'),
                    )),
              ],
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }
}
