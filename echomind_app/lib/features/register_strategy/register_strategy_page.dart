import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';

class RegisterStrategyPage extends StatelessWidget {
  const RegisterStrategyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('注册策略')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction_rounded,
                size: 64, color: AppTheme.textSecondary),
            const SizedBox(height: 16),
            Text('功能开发中',
                style: TextStyle(
                    fontSize: 18, color: AppTheme.textSecondary)),
            const SizedBox(height: 8),
            Text('注册策略功能即将上线，敬请期待',
                style: TextStyle(
                    fontSize: 14, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}
