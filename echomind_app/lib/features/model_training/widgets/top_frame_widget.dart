import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TopFrameWidget extends StatelessWidget {
  final String modelName;
  const TopFrameWidget({super.key, this.modelName = ''});

  @override
  Widget build(BuildContext context) {
    final title = modelName.isNotEmpty ? '$modelName · 训练' : '模型训练';
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          ),
          Expanded(
            child: Text(title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
