import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/providers/model_detail_provider.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';

class TopFrameWidget extends ConsumerWidget {
  final String modelId;

  const TopFrameWidget({super.key, required this.modelId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(modelDetailProvider(modelId));
    final title = detail.whenOrNull(data: (d) => d.name.trim()) ?? '';
    final displayTitle = title.isEmpty ? '受力分析' : title;

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
              displayTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.heading(size: 20, weight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}
