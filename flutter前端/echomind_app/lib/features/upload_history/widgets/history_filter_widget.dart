import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';

class HistoryFilterWidget extends StatefulWidget {
  final List<String> filters;
  final ValueChanged<int>? onChanged;

  const HistoryFilterWidget({
    super.key,
    this.filters = const ['全部', '待诊断', '已完成', '作业', '考试'],
    this.onChanged,
  });

  @override
  State<HistoryFilterWidget> createState() => _HistoryFilterWidgetState();
}

class _HistoryFilterWidgetState extends State<HistoryFilterWidget> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
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
            for (int i = 0; i < widget.filters.length; i++) ...[
              if (i > 0) const SizedBox(width: 4),
              GestureDetector(
                onTap: () {
                  setState(() => _selected = i);
                  widget.onChanged?.call(i);
                },
                child: _chip(widget.filters[i], _selected == i),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static Widget _chip(String label, bool selected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: selected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: selected
            ? [
                const BoxShadow(offset: Offset(2, 2), blurRadius: 6, color: Color(0x22000000)),
                const BoxShadow(offset: Offset(-2, -2), blurRadius: 6, color: Color(0x44FFFFFF)),
              ]
            : [],
      ),
      child: Text(label,
          style: AppTheme.label(
            size: 13,
            color: selected ? AppTheme.accent : AppTheme.muted,
          )),
    );
  }
}
