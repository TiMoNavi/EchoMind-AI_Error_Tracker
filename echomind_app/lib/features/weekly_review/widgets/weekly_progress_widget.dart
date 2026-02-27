import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/providers/weekly_review_provider.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';

class WeeklyProgressWidget extends ConsumerWidget {
  const WeeklyProgressWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(weeklyReviewProvider);

    final entries = asyncData.when(
      loading: () => _fallbackEntries,
      error: (_, __) => _fallbackEntries,
      data: (data) {
        if (data.progressItems.isEmpty) return _fallbackEntries;
        return List<_ProgressEntry>.generate(data.progressItems.length, (i) {
          final text = data.progressItems[i];
          return _entryFromText(text, i);
        });
      },
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('本周进展',
              style: AppTheme.heading(size: 18, weight: FontWeight.w900)),
          const SizedBox(height: 12),
          Column(
            children: [
              for (var i = 0; i < entries.length; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                _buildItem(entries[i]),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItem(_ProgressEntry entry) {
    return ClayCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: entry.dotColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: entry.dotColor.withValues(alpha: 0.4),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: AppTheme.body(size: 14, weight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(entry.desc, style: AppTheme.label(size: 12)),
              ],
            ),
          ),
          Text(
            entry.status,
            style: AppTheme.label(
              size: 13,
              color: entry.isUp ? AppTheme.accent : AppTheme.muted,
            ),
          ),
        ],
      ),
    );
  }

  _ProgressEntry _entryFromText(String text, int index) {
    final normalized = text.trim();
    final parts = normalized.split(RegExp(r'\s*[-—–]{1,2}\s*'));
    final name = parts.isNotEmpty && parts.first.isNotEmpty
        ? parts.first
        : '学习项 ${index + 1}';
    final desc = normalized;

    final lower = normalized.toLowerCase();
    final isUp = lower.contains('提升') ||
        lower.contains('完成') ||
        lower.contains('通过') ||
        lower.contains('掌握') ||
        lower.contains('up');

    final dotColor = switch (index % 3) {
      0 => AppTheme.success,
      1 => AppTheme.warning,
      _ => AppTheme.danger,
    };

    return _ProgressEntry(
      name: name,
      desc: desc,
      status: isUp ? 'UP' : '--',
      isUp: isUp,
      dotColor: dotColor,
    );
  }

  static const _fallbackEntries = [
    _ProgressEntry(
      name: '匀变速直线运动',
      desc: 'L3 --> L4 -- 做对过',
      status: 'UP',
      isUp: true,
      dotColor: AppTheme.success,
    ),
    _ProgressEntry(
      name: '牛顿第二定律应用',
      desc: 'L2 --> L3 -- 执行正确一次',
      status: 'UP',
      isUp: true,
      dotColor: AppTheme.warning,
    ),
    _ProgressEntry(
      name: '板块运动',
      desc: 'L1 --> L1 -- 仍在建模层卡住',
      status: '--',
      isUp: false,
      dotColor: AppTheme.danger,
    ),
  ];
}

class _ProgressEntry {
  final String name;
  final String desc;
  final String status;
  final bool isUp;
  final Color dotColor;

  const _ProgressEntry({
    required this.name,
    required this.desc,
    required this.status,
    required this.isUp,
    required this.dotColor,
  });
}
