import 'package:flutter/material.dart';
import 'package:echomind_app/shared/widgets/page_shell.dart';
import 'package:echomind_app/features/global_model/widgets/top_frame_widget.dart';
import 'package:echomind_app/features/global_model/widgets/model_tree_widget.dart';

class GlobalModelPage extends StatelessWidget {
  const GlobalModelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageShell(
      tabIndex: 1,
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: const [
          TopFrameWidget(),
          SizedBox(height: 4),
          ModelTreeWidget(),
        ],
      ),
    );
  }
}
