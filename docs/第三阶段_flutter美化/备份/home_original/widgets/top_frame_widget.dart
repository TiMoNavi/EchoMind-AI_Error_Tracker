import 'package:flutter/material.dart';

class TopFrameWidget extends StatelessWidget {
  final String title;
  const TopFrameWidget({super.key, this.title = '主页'});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
