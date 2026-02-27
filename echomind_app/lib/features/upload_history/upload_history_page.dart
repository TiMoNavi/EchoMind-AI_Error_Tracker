import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/features/upload_history/widgets/history_date_scroll_widget.dart';
import 'package:echomind_app/features/upload_history/widgets/history_filter_widget.dart';
import 'package:echomind_app/features/upload_history/widgets/history_record_list_widget.dart';
import 'package:echomind_app/features/upload_history/widgets/history_timeline_widget.dart';
import 'package:echomind_app/features/upload_history/widgets/top_frame_widget.dart';
import 'package:echomind_app/providers/upload_history_provider.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_background_blobs.dart';

class UploadHistoryPage extends ConsumerWidget {
  const UploadHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(uploadHistoryProvider);

    return Scaffold(
      backgroundColor: AppTheme.canvas,
      body: SafeArea(
        child: Column(
          children: [
            const TopFrameWidget(),
            const HistoryFilterWidget(),
            const SizedBox(height: 12),
            const HistoryDateScrollWidget(),
            const SizedBox(height: 12),
            Expanded(
              child: Stack(
                children: [
                  const ClayBackgroundBlobs(),
                  Column(
                    children: const [
                      HistoryTimelineWidget(),
                      SizedBox(height: 12),
                      Expanded(child: HistoryRecordListWidget()),
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
