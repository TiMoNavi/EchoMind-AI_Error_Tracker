import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/app/app_routes.dart';

// Level colors: L0=red, L1=orange, L2=yellow, L3=blue, L4=green, L5=deep green
Color _levelColor(int level) => switch (level) {
  0 => const Color(0xFFEF4444),
  1 => const Color(0xFFF59E0B),
  2 => const Color(0xFFEAB308),
  3 => const Color(0xFF0EA5E9),
  4 => const Color(0xFF10B981),
  _ => const Color(0xFF059669),
};

String _levelLabel(int level) => switch (level) {
  0 => '未掌握',
  1 => '薄弱',
  2 => '一般',
  3 => '良好',
  4 => '熟练',
  _ => '精通',
};

class KnowledgeTreeWidget extends StatefulWidget {
  const KnowledgeTreeWidget({super.key});

  @override
  State<KnowledgeTreeWidget> createState() => _KnowledgeTreeWidgetState();
}

class _KnowledgeTreeWidgetState extends State<KnowledgeTreeWidget> {
  int _subject = 0;
  final _expandedL1 = <int>{0};
  final _expandedL2 = <String>{'0-0'};

  static const _tree = [
    (
      title: '力学', level: 4,
      sections: [
        (title: '力的概念', level: 5, count: '3/3', items: [
          (title: '力的定义', level: 5),
          (title: '力的三要素', level: 4),
          (title: '力的单位', level: 5),
        ]),
        (title: '牛顿运动定律', level: 3, count: '2/3', items: [
          (title: '牛顿第一定律', level: 4),
          (title: '牛顿第二定律', level: 3),
          (title: '牛顿第三定律', level: 5),
        ]),
        (title: '摩擦力', level: 2, count: '0/2', items: [
          (title: '静摩擦力', level: 2),
          (title: '滑动摩擦力', level: 3),
        ]),
      ],
    ),
    (
      title: '静电场', level: 3,
      sections: [
        (title: '电荷', level: 4, count: '3/3', items: [
          (title: '电荷量', level: 4),
          (title: '元电荷', level: 4),
          (title: '起电方式', level: 5),
        ]),
        (title: '库仑定律', level: 2, count: '0/2', items: [
          (title: '库仑定律公式', level: 3),
          (title: '适用条件', level: 2),
        ]),
      ],
    ),
    (
      title: '电磁感应', level: 0,
      sections: [
        (title: '法拉第电磁感应定律', level: 1, count: '0/2', items: [
          (title: '感应电动势', level: 1),
          (title: '磁通量变化率', level: 0),
        ]),
        (title: '楞次定律', level: 0, count: '0/2', items: [
          (title: '楞次定律内容', level: 1),
          (title: '应用方法', level: 0),
        ]),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Subject filter chips
          Row(children: [
            _ClayFilterChip(label: '物理', active: _subject == 0, onTap: () => setState(() => _subject = 0)),
            const SizedBox(width: 10),
            _ClayFilterChip(label: '数学', active: _subject == 1, onTap: () => setState(() => _subject = 1)),
          ]),
          const SizedBox(height: 16),
          // Tree chapters
          for (var ci = 0; ci < _tree.length; ci++) ...[
            if (ci > 0) const SizedBox(height: 14),
            _buildChapter(ci),
          ],
        ],
      ),
    );
  }

  Widget _buildChapter(int ci) {
    final ch = _tree[ci];
    final open = _expandedL1.contains(ci);
    final color = _levelColor(ch.level);

    return ClayCard(
      radius: AppTheme.radiusCard,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Chapter header
          GestureDetector(
            onTap: () => setState(() => open ? _expandedL1.remove(ci) : _expandedL1.add(ci)),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
              child: Row(
                children: [
                  // Colored accent bar
                  Container(
                    width: 4,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ch.title,
                          style: AppTheme.heading(size: 22, weight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${ch.sections.length} 个小节',
                          style: AppTheme.label(size: 13, color: AppTheme.muted),
                        ),
                      ],
                    ),
                  ),
                  _LevelPill(ch.level),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: open ? 0.25 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      size: 24,
                      color: AppTheme.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Sections
          if (open)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                children: [
                  for (var si = 0; si < ch.sections.length; si++) ...[
                    if (si > 0) const SizedBox(height: 10),
                    _buildSection(ci, si),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSection(int ci, int si) {
    final sec = _tree[ci].sections[si];
    final key = '$ci-$si';
    final open = _expandedL2.contains(key);
    final color = _levelColor(sec.level);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.canvas,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
      ),
      child: Column(
        children: [
          // Section header
          GestureDetector(
            onTap: () => setState(() => open ? _expandedL2.remove(key) : _expandedL2.add(key)),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      sec.title,
                      style: AppTheme.body(size: 18, weight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    sec.count,
                    style: AppTheme.label(size: 14, color: AppTheme.muted),
                  ),
                  const SizedBox(width: 6),
                  AnimatedRotation(
                    turns: open ? 0.25 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: AppTheme.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Knowledge items
          if (open)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                children: [
                  for (final item in sec.items)
                    _buildItem(item.title, item.level),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildItem(String title, int level) {
    final color = _levelColor(level);
    return GestureDetector(
      onTap: () => context.push(AppRoutes.knowledgeDetail),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(top: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        child: Row(
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: AppTheme.body(size: 16, weight: FontWeight.w500),
              ),
            ),
            _LevelPill(level),
          ],
        ),
      ),
    );
  }
}

// ─── Clay Filter Chip ───
class _ClayFilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _ClayFilterChip({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppTheme.accent : Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          boxShadow: active
              ? AppTheme.shadowClayButton
              : AppTheme.shadowClayStatOrb,
        ),
        child: Text(
          label,
          style: AppTheme.label(
            size: 16,
            color: active ? Colors.white : AppTheme.muted,
          ).copyWith(
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ─── Level Pill Badge ───
class _LevelPill extends StatelessWidget {
  final int level;
  const _LevelPill(this.level);

  @override
  Widget build(BuildContext context) {
    final color = _levelColor(level);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Text(
        _levelLabel(level),
        style: AppTheme.label(size: 13, color: color).copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
