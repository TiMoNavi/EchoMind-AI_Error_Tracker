import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';

/// Claymorphism-styled loading skeleton placeholder.
///
/// Shows a pulsing shimmer animation inside a ClayCard.
class ClayLoadingState extends StatefulWidget {
  final int itemCount;
  final double itemHeight;

  const ClayLoadingState({
    super.key,
    this.itemCount = 3,
    this.itemHeight = 80,
  });

  @override
  State<ClayLoadingState> createState() => _ClayLoadingStateState();
}

class _ClayLoadingStateState extends State<ClayLoadingState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            for (int i = 0; i < widget.itemCount; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              _SkeletonCard(height: widget.itemHeight),
            ],
          ],
        ),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  final double height;
  const _SkeletonCard({required this.height});

  @override
  Widget build(BuildContext context) {
    return ClayCard(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: height - 32,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _bar(width: 120, height: 12),
            const SizedBox(height: 10),
            _bar(width: double.infinity, height: 10),
            const SizedBox(height: 8),
            _bar(width: 180, height: 10),
          ],
        ),
      ),
    );
  }

  static Widget _bar({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.canvas,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
    );
  }
}