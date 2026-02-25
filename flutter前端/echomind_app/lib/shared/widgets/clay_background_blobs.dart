import 'package:flutter/material.dart';

/// Animated floating blobs that create ambient colored lighting behind content.
class ClayBackgroundBlobs extends StatefulWidget {
  const ClayBackgroundBlobs({super.key});

  @override
  State<ClayBackgroundBlobs> createState() => _ClayBackgroundBlobsState();
}

class _ClayBackgroundBlobsState extends State<ClayBackgroundBlobs>
    with TickerProviderStateMixin {
  late final AnimationController _ctrl1;
  late final AnimationController _ctrl2;
  late final AnimationController _ctrl3;

  @override
  void initState() {
    super.initState();
    _ctrl1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
    _ctrl2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
    _ctrl3 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl1.dispose();
    _ctrl2.dispose();
    _ctrl3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    final blobSize = mq.width * 0.7;

    return IgnorePointer(
      child: SizedBox.expand(
        child: Stack(
          children: [
            // Violet blob — top left
            _AnimatedBlob(
              controller: _ctrl1,
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.10),
              size: blobSize,
              startOffset: Offset(-blobSize * 0.3, -blobSize * 0.2),
              drift: const Offset(0, -20),
            ),
            // Pink blob — right
            _AnimatedBlob(
              controller: _ctrl2,
              color: const Color(0xFFEC4899).withValues(alpha: 0.08),
              size: blobSize * 0.8,
              startOffset: Offset(mq.width * 0.5, mq.height * 0.15),
              drift: const Offset(0, -15),
            ),
            // Sky blue blob — bottom
            _AnimatedBlob(
              controller: _ctrl3,
              color: const Color(0xFF0EA5E9).withValues(alpha: 0.08),
              size: blobSize * 0.9,
              startOffset: Offset(-blobSize * 0.1, mq.height * 0.5),
              drift: const Offset(0, -25),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedBlob extends AnimatedWidget {
  final Color color;
  final double size;
  final Offset startOffset;
  final Offset drift;

  const _AnimatedBlob({
    required AnimationController controller,
    required this.color,
    required this.size,
    required this.startOffset,
    required this.drift,
  }) : super(listenable: controller);

  @override
  Widget build(BuildContext context) {
    final t = (listenable as AnimationController).value;
    return Positioned(
      left: startOffset.dx + drift.dx * t,
      top: startOffset.dy + drift.dy * t,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}
