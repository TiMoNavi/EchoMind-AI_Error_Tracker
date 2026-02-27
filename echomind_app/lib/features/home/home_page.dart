import 'package:flutter/material.dart';
import 'package:echomind_app/shared/widgets/page_shell.dart';
import 'package:echomind_app/shared/widgets/clay_background_blobs.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/features/home/widgets/top_frame_widget.dart';
import 'package:echomind_app/features/home/widgets/top_dashboard_widget.dart';
import 'package:echomind_app/features/home/widgets/recommendation_list_widget.dart';
import 'package:echomind_app/features/home/widgets/recent_upload_widget.dart';
import 'package:echomind_app/features/home/widgets/action_overlay_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/app/app_routes.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageShell(
      tabIndex: 0,
      body: Stack(
        children: [
          const ClayBackgroundBlobs(),
          ListView(
            clipBehavior: Clip.none,
            padding: const EdgeInsets.only(bottom: 24),
            children: const [
              TopFrameWidget(title: '主页'),
              SizedBox(height: 8),
              TopDashboardWidget(),
              SizedBox(height: 28),
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: UploadErrorCardWidget(),
              ),
              SizedBox(height: 24),
              RecommendationListWidget(),
              SizedBox(height: 20),
              RecentUploadWidget(),
            ],
          ),
          Positioned(
            right: 20,
            bottom: 20,
            child: _ClayFab(
              onTap: () => context.push(AppRoutes.uploadMenu),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClayFab extends StatelessWidget {
  final VoidCallback onTap;
  const _ClayFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: AppTheme.gradientPrimary,
          shape: BoxShape.circle,
          boxShadow: AppTheme.shadowClayButton,
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
