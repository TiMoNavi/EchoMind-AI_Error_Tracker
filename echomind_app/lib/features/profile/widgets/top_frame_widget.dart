import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';

class TopFrameWidget extends StatelessWidget {
  const TopFrameWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Text('我的', style: AppTheme.heading(size: 28)),
    );
  }
}
