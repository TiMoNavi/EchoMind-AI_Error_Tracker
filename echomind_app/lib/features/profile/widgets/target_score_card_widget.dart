import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/providers/profile_provider.dart';

class TargetScoreCardWidget extends ConsumerWidget {
  const TargetScoreCardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    if (profile.loading) return const SizedBox.shrink();
    if (profile.student == null) return _buildCard(target: 0, subject: '--');
    return _buildCard(target: profile.student!.targetScore, subject: profile.student!.subject);
  }

  Widget _buildCard({required int target, required String subject}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('目标分数', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('$target', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                    const SizedBox(width: 4),
                    Text('分 ($subject)', style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                  ],
                ),
              ],
            ),
            TextButton(onPressed: () {}, child: const Text('修改')),
          ],
        ),
      ),
    );
  }
}
