import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';
import 'package:google_fonts/google_fonts.dart';

/// Claymorphism-styled error state.
///
/// Shows a friendly error message with a retry button inside a ClayCard.
class ClayErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ClayErrorState({
    super.key,
    this.message = '加载失败，请稍后重试',
    this.onRetry,
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
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              _retryButton(),
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
        gradient: AppTheme.gradientPink,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            offset: const Offset(4, 4),
            blurRadius: 10,
            color: AppTheme.accentAlt.withValues(alpha: 0.25),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.cloud_off_rounded,
        color: Colors.white,
        size: 28,
      ),
    );
  }

  Widget _retryButton() {
    return SizedBox(
      height: 44,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.gradientPrimary,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          boxShadow: AppTheme.shadowClayButton,
        ),
        child: ElevatedButton(
          onPressed: onRetry,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
            elevation: 0,
          ),
          child: Text(
            '重新加载',
            style: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}