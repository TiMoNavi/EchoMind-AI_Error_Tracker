import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';

/// Reusable Claymorphism card with multi-layer shadows and super-rounded corners.
class ClayCard extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final List<BoxShadow>? shadows;
  final VoidCallback? onTap;

  const ClayCard({
    super.key,
    required this.child,
    this.radius = 32,
    this.padding = const EdgeInsets.all(20),
    this.color,
    this.shadows,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: shadows ?? AppTheme.shadowClayCard,
      ),
      child: child,
    );

    if (onTap == null) return card;

    return GestureDetector(
      onTap: onTap,
      child: card,
    );
  }
}
