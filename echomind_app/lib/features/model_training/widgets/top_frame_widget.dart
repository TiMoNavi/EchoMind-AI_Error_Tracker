import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';

class TopFrameWidget extends StatelessWidget {
  final String modelName;

  const TopFrameWidget({super.key, this.modelName = ''});

  @override
  Widget build(BuildContext context) {
    final title =
        modelName.trim().isEmpty ? '模型训练' : '${modelName.trim()} · 训练';

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          ),
          Expanded(
            child: Text(
              title,
              style: AppTheme.heading(size: 21, weight: FontWeight.w900),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
