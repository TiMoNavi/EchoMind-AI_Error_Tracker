import 'package:flutter/material.dart';
import 'package:echomind_app/features/prediction_center/widgets/priority_model_list_widget.dart';
import 'package:echomind_app/features/prediction_center/widgets/score_card_widget.dart';
import 'package:echomind_app/features/prediction_center/widgets/score_path_table_widget.dart';
import 'package:echomind_app/features/prediction_center/widgets/top_frame_widget.dart';
import 'package:echomind_app/features/prediction_center/widgets/trend_card_widget.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_background_blobs.dart';

class PredictionCenterPage extends StatelessWidget {
  const PredictionCenterPage({super.key});

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
                    padding: const EdgeInsets.only(bottom: 28),
                    children: const [
                      ScoreCardWidget(),
                      SizedBox(height: 20),
                      TrendCardWidget(),
                      SizedBox(height: 24),
                      ScorePathTableWidget(),
                      SizedBox(height: 24),
                      PriorityModelListWidget(),
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
