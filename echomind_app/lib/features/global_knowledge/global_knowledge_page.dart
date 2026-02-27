import 'package:flutter/material.dart';
import 'package:echomind_app/shared/widgets/page_shell.dart';
import 'package:echomind_app/shared/widgets/clay_background_blobs.dart';
import 'package:echomind_app/features/global_knowledge/widgets/top_frame_widget.dart';
import 'package:echomind_app/features/global_knowledge/widgets/knowledge_tree_widget.dart';

class GlobalKnowledgePage extends StatelessWidget {
  const GlobalKnowledgePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageShell(
      tabIndex: 1,
      body: Stack(
        children: [
          const ClayBackgroundBlobs(),
          ListView(
            clipBehavior: Clip.none,
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              TopFrameWidget(activeTab: 0, onTabChanged: (_) {}),
              const SizedBox(height: 4),
              const KnowledgeTreeWidget(),
            ],
          ),
        ],
      ),
    );
  }
}
