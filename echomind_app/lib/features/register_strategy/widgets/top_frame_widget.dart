import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
          const Text('卷面策略',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
