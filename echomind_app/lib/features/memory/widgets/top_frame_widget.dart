import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';

class TopFrameWidget extends StatelessWidget {
  final String title;

  const TopFrameWidget({super.key, this.title = '记忆'});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Text(
        title,
        style: AppTheme.heading(size: 30, weight: FontWeight.w900),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
