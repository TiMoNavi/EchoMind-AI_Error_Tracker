import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';

class TopFrameWidget extends StatelessWidget {
  const TopFrameWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          ),
          Text('卷面策略',
              style: AppTheme.heading(size: 22, weight: FontWeight.w900)),
        ],
      ),
    );
  }
}
