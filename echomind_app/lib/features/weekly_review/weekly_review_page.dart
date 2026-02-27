import 'package:flutter/material.dart';
import 'package:echomind_app/features/weekly_review/widgets/next_week_focus_widget.dart';
import 'package:echomind_app/features/weekly_review/widgets/score_change_widget.dart';
import 'package:echomind_app/features/weekly_review/widgets/top_frame_widget.dart';
import 'package:echomind_app/features/weekly_review/widgets/weekly_dashboard_widget.dart';
import 'package:echomind_app/features/weekly_review/widgets/weekly_progress_widget.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_background_blobs.dart';

class WeeklyReviewPage extends StatelessWidget {
  const WeeklyReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      body: SafeArea(
        child: Column(
          children: [
            const TopFrameWidget(),
            Expanded(
              child: Stack(
                children: [
                  const ClayBackgroundBlobs(),
                  ListView(
                    clipBehavior: Clip.none,
                    padding: const EdgeInsets.only(bottom: 24),
                    children: const [
                      WeeklyDashboardWidget(),
                      SizedBox(height: 20),
                      ScoreChangeWidget(),
                      SizedBox(height: 24),
                      WeeklyProgressWidget(),
                      SizedBox(height: 24),
                      NextWeekFocusWidget(),
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
}
