import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';

class TopFrameWidget extends StatelessWidget {
  final String title;
  const TopFrameWidget({super.key, this.title = '主页'});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTheme.heading(size: 32, weight: FontWeight.w900),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Decorative clay orb
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.8),
              boxShadow: AppTheme.shadowClayStatOrb,
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: AppTheme.accent,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          // User avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.gradientPrimary,
              boxShadow: AppTheme.shadowClayStatOrb,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}
