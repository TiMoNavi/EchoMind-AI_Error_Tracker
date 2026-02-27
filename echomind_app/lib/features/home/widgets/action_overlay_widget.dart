import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/app/app_routes.dart';

/// Legacy export kept so old imports don't break.
class ActionOverlayWidget extends StatelessWidget {
  const ActionOverlayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const UploadErrorCardWidget();
  }
}

class UploadErrorCardWidget extends StatelessWidget {
  const UploadErrorCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _OverflowCard(
              icon: Icons.camera_alt_rounded,
              label: '拍照上传',
              rotation: -12,
              onTap: () => context.push(AppRoutes.uploadMenu),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _OverflowCard(
              icon: Icons.description_rounded,
              label: '文本上传',
              rotation: 10,
              onTap: () => context.push(AppRoutes.uploadMenu),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverflowCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final double rotation;
  final VoidCallback onTap;

  const _OverflowCard({
    required this.icon,
    required this.label,
    required this.rotation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 140,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0, right: 0, top: 20, bottom: 0,
              child: ClayCard(
                radius: 24,
                padding: EdgeInsets.zero,
                child: const SizedBox.expand(),
              ),
            ),
            _buildBigIcon(),
            _buildLabel(),
          ],
        ),
      ),
    );
  }

  Widget _buildBigIcon() {
    return Positioned(
      top: -28, left: 0, right: 0,
      child: Center(
        child: Transform.rotate(
          angle: rotation * math.pi / 180,
          child: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF42A5F5),
                Color(0xFF1E88E5),
                Color(0xFF26C6DA),
              ],
              stops: [0.0, 0.5, 1.0],
            ).createShader(bounds),
            blendMode: BlendMode.srcIn,
            child: Icon(
              icon, size: 110, color: Colors.white,
              shadows: const [
                Shadow(
                  offset: Offset(0, 6),
                  blurRadius: 24,
                  color: Color(0x6090CAF9),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel() {
    return Positioned(
      left: 0, right: 0, bottom: 14,
      child: Center(
        child: Text(
          label,
          style: AppTheme.heading(size: 16, weight: FontWeight.w700),
        ),
      ),
    );
  }
}
