import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';

class HistoryFilterWidget extends StatefulWidget {
  const HistoryFilterWidget({super.key});

  @override
  State<HistoryFilterWidget> createState() => _HistoryFilterWidgetState();
}

class _HistoryFilterWidgetState extends State<HistoryFilterWidget> {
  static const _filters = ['全部', '待诊断', '已完成'];
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppTheme.canvas,
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          boxShadow: AppTheme.shadowClayPressed,
        ),
        child: Row(
          children: [
            for (var i = 0; i < _filters.length; i++) ...[
              if (i > 0) const SizedBox(width: 4),
              GestureDetector(
                onTap: () => setState(() => _selected = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: _selected == i ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    boxShadow: _selected == i
                        ? const [
                            BoxShadow(
                              offset: Offset(2, 2),
                              blurRadius: 6,
                              color: Color(0x22000000),
                            ),
                            BoxShadow(
                              offset: Offset(-2, -2),
                              blurRadius: 6,
                              color: Color(0x44FFFFFF),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    _filters[i],
                    style: AppTheme.label(
                      size: 13,
                      color: _selected == i ? AppTheme.accent : AppTheme.muted,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
