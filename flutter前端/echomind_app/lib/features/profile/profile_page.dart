import 'package:flutter/material.dart';
import 'package:echomind_app/shared/widgets/page_shell.dart';
import 'package:echomind_app/shared/widgets/clay_background_blobs.dart';
import 'package:echomind_app/features/profile/widgets/top_frame_widget.dart';
import 'package:echomind_app/features/profile/widgets/user_info_card_widget.dart';
import 'package:echomind_app/features/profile/widgets/target_score_card_widget.dart';
import 'package:echomind_app/features/profile/widgets/learning_stats_widget.dart';
import 'package:echomind_app/features/profile/widgets/three_row_navigation_widget.dart';
import 'package:echomind_app/features/profile/widgets/two_row_navigation_widget.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageShell(
      tabIndex: 4,
      body: Stack(
        children: [
          const ClayBackgroundBlobs(),
          ListView(
            clipBehavior: Clip.none,
            padding: const EdgeInsets.only(bottom: 24),
            children: const [
              TopFrameWidget(),
              SizedBox(height: 12),
              UserInfoCardWidget(),
              SizedBox(height: 20),
              TargetScoreCardWidget(),
              SizedBox(height: 20),
              ThreeRowNavigationWidget(),
              SizedBox(height: 20),
              TwoRowNavigationWidget(),
              SizedBox(height: 24),
              LearningStatsWidget(),
            ],
          ),
        ],
      ),
    );
  }
}
