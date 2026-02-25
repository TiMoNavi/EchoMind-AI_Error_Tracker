import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';

/// Claymorphism-styled empty state.
///
/// Shows a friendly message when there's no data to display.
class ClayEmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  final Widget? action;

  const ClayEmptyState({
    super.key,
    this.message = '暂无数据',
    this.icon = Icons.inbox_rounded,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: ClayCard(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _iconOrb(),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTheme.body(size: 15, color: AppTheme.muted),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: 20),
              action!,
            ],
          ],
        ),
      ),
    );
  }

  Widget _iconOrb() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: AppTheme.gradientBlue,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            offset: const Offset(4, 4),
            blurRadius: 10,
            color: AppTheme.tertiary.withValues(alpha: 0.25),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: Colors.white, size: 28),
    );
  }
}
