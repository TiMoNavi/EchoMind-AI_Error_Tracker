import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';

class BoardFeatureBoostWidget extends StatelessWidget {
  const BoardFeatureBoostWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClayCard(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        child: Column(
          children: [
            Text('--', style: AppTheme.label(size: 48)),
            const SizedBox(height: 12),
            Text('新功能投票', style: AppTheme.heading(size: 16)),
            const SizedBox(height: 4),
            Text('为你最想要的功能投票, 票数越高优先开发',
                style: AppTheme.label(size: 13),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
