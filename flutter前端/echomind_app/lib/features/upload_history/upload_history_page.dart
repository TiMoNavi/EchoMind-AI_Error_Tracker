import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_background_blobs.dart';
import 'package:echomind_app/features/upload_history/widgets/top_frame_widget.dart';
import 'package:echomind_app/features/upload_history/widgets/history_filter_widget.dart';
import 'package:echomind_app/features/upload_history/widgets/history_record_list_widget.dart';

class UploadHistoryPage extends StatelessWidget {
  const UploadHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      body: SafeArea(
        child: Column(
          children: [
            const TopFrameWidget(),
            const HistoryFilterWidget(),
            const SizedBox(height: 12),
            Expanded(
              child: Stack(
                children: [
                  const ClayBackgroundBlobs(),
                  const HistoryRecordListWidget(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
