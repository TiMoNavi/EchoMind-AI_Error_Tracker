import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class UserInfoCardWidget extends StatelessWidget {
  final String name;
  final String initial;
  final String subtitle;
  final List<String> tags;

  const UserInfoCardWidget({
    super.key,
    this.name = '同学 S',
    this.initial = 'S',
    this.subtitle = '天津 -- 高三 -- 物理+数学',
    this.tags = const ['完整订阅', '2026.3.15到期'],
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppTheme.gradientHero,
          borderRadius: BorderRadius.circular(AppTheme.radiusHero),
          boxShadow: AppTheme.shadowClayCard,
        ),
        child: Row(
          children: [
            _avatarOrb(),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTheme.heading(size: 22)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppTheme.label(size: 13)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: [
                      for (int i = 0; i < tags.length; i++)
                        _tag(tags[i], accent: i == 0),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatarOrb() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        gradient: AppTheme.gradientPrimary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.accent.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: GoogleFonts.nunito(
          fontSize: 28,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
    );
  }

  static Widget _tag(String text, {bool accent = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: accent ? AppTheme.accent : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Text(
        text,
        style: AppTheme.label(
          size: 12,
          color: accent ? Colors.white : AppTheme.muted,
        ),
      ),
    );
  }
}
