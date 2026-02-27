import 'package:flutter/material.dart';
import 'package:echomind_app/shared/widgets/main_bottom_nav.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';

/// Shell wrapper for tab pages — provides SafeArea + bottom nav.
class PageShell extends StatelessWidget {
  final int tabIndex;
  final Widget body;
  const PageShell({super.key, required this.tabIndex, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      body: SafeArea(child: body),
      bottomNavigationBar: MainBottomNav(currentIndex: tabIndex),
    );
  }
}
