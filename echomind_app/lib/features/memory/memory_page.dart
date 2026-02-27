import 'package:flutter/material.dart';
import 'package:echomind_app/shared/widgets/page_shell.dart';
import 'package:echomind_app/shared/widgets/clay_background_blobs.dart';
import 'package:echomind_app/features/memory/widgets/top_frame_widget.dart';
import 'package:echomind_app/features/memory/widgets/review_dashboard_widget.dart';
import 'package:echomind_app/features/memory/widgets/card_category_list_widget.dart';

class MemoryPage extends StatelessWidget {
  const MemoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageShell(
      tabIndex: 2,
      body: Stack(
        children: [
          const ClayBackgroundBlobs(),
          ListView(
            clipBehavior: Clip.none,
            padding: const EdgeInsets.only(bottom: 40),
            children: const [
              TopFrameWidget(),
              SizedBox(height: 8),
              ReviewDashboardWidget(),
              SizedBox(height: 20),
              CardCategoryListWidget(),
            ],
          ),
        ],
      ),
    );
  }
}
