import 'package:flutter/material.dart';
import 'package:echomind_app/shared/widgets/page_shell.dart';
import 'package:echomind_app/shared/widgets/clay_background_blobs.dart';
import 'package:echomind_app/features/community/widgets/top_frame_and_tabs_widget.dart';
import 'package:echomind_app/features/community/widgets/board_my_requests_widget.dart';
import 'package:echomind_app/features/community/widgets/board_feature_boost_widget.dart';
import 'package:echomind_app/features/community/widgets/board_feedback_widget.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  int _tab = 0;

  static const _boards = [
    BoardMyRequestsWidget(),
    BoardFeatureBoostWidget(),
    BoardFeedbackWidget(),
  ];

  @override
  Widget build(BuildContext context) {
    return PageShell(
      tabIndex: 3,
      body: Stack(
        children: [
          const ClayBackgroundBlobs(),
          ListView(
            clipBehavior: Clip.none,
            padding: const EdgeInsets.only(bottom: 40),
            children: [
              TopFrameAndTabsWidget(
                activeTab: _tab,
                onTabChanged: (i) => setState(() => _tab = i),
              ),
              _boards[_tab],
            ],
          ),
        ],
      ),
    );
  }
}
