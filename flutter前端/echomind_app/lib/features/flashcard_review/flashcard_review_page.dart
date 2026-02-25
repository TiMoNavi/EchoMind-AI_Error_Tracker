import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_background_blobs.dart';
import 'package:echomind_app/features/flashcard_review/widgets/top_frame_widget.dart';
import 'package:echomind_app/features/flashcard_review/widgets/flashcard_widget.dart';

class FlashcardReviewPage extends StatelessWidget {
  const FlashcardReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      body: SafeArea(
        child: Stack(
          children: [
            const ClayBackgroundBlobs(),
            const Column(
              children: [
                TopFrameWidget(),
                Expanded(child: FlashcardWidget()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
