import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';

class TopFrameAndTabsWidget extends StatelessWidget {
  final int activeTab;
  final ValueChanged<int> onTabChanged;
  const TopFrameAndTabsWidget({super.key, required this.activeTab, required this.onTabChanged});

  static const _tabs = ['我的需求', '功能助推', '反馈墙'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Text('社区', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFEFEBF5),
              borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              boxShadow: AppTheme.shadowClayPressed,
            ),
            child: Row(
              children: [
                for (var i = 0; i < _tabs.length; i++) ...[
                  if (i > 0) const SizedBox(width: 4),
                  Expanded(child: _TabChip(label: _tabs[i], active: i == activeTab, onTap: () => onTabChanged(i))),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _TabChip({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          boxShadow: active
              ? [
                  const BoxShadow(offset: Offset(2, 2), blurRadius: 6, color: Color(0x22000000)),
                  const BoxShadow(offset: Offset(-2, -2), blurRadius: 6, color: Color(0x44FFFFFF)),
                ]
              : [],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTheme.label(size: 14,
              color: active ? AppTheme.accent : AppTheme.muted),
        ),
      ),
    );
  }
}
