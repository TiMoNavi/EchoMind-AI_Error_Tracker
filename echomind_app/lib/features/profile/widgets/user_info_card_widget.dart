import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/providers/profile_provider.dart';

class UserInfoCardWidget extends ConsumerWidget {
  const UserInfoCardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    return profile.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => _buildCard(name: '同学', region: '--', subject: '--'),
      data: (user) => _buildCard(
        name: user.nickname ?? '同学',
        region: user.regionId,
        subject: user.subject,
      ),
    );
  }

  Widget _buildCard({required String name, required String region, required String subject}) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'S';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
        child: Row(children: [
          Container(
            width: 60, height: 60,
            decoration: const BoxDecoration(color: AppTheme.background, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(initial, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppTheme.textSecondary)),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text('$region -- $subject', style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            ],
          )),
        ]),
      ),
    );
  }
}
