import 'package:flutter/material.dart';
import 'package:echomind_app/features/global_model/widgets/model_tree_widget.dart';
import 'package:echomind_app/features/global_model/widgets/top_frame_widget.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_background_blobs.dart';

class GlobalModelPage extends StatelessWidget {
  const GlobalModelPage({super.key});

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
                    padding: const EdgeInsets.only(bottom: 32),
                    children: const [
                      SizedBox(height: 4),
                      ModelTreeWidget(),
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
