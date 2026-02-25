import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/app/app_routes.dart';

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

class ModelTreeWidget extends StatefulWidget {
  const ModelTreeWidget({super.key});

  @override
  State<ModelTreeWidget> createState() => _ModelTreeWidgetState();
}

class _ModelTreeWidgetState extends State<ModelTreeWidget> {
  final _expanded = <int>{0};

  static const _tree = [
    (
      title: '受力分析模型', level: 4, count: '4/5',
      items: [
        (title: '整体法与隔离法', level: 5),
        (title: '共点力平衡', level: 4),
        (title: '斜面体模型', level: 3),
        (title: '连接体模型', level: 4),
        (title: '板块运动', level: 2),
      ],
    ),
    (
      title: '运动学模型', level: 3, count: '2/4',
      items: [
        (title: '匀变速直线运动', level: 4),
        (title: '抛体运动', level: 3),
        (title: '圆周运动', level: 2),
        (title: '追及相遇', level: 1),
      ],
    ),
    (
      title: '能量守恒模型', level: 1, count: '1/3',
      items: [
        (title: '动能定理应用', level: 2),
        (title: '机械能守恒', level: 1),
        (title: '功能关系', level: 0),
      ],
    ),
    (
      title: '电磁学模型', level: 0, count: '0/3',
      items: [
        (title: '带电粒子在电场中运动', level: 1),
        (title: '带电粒子在磁场中运动', level: 0),
        (title: '电磁感应综合', level: 0),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          for (var ci = 0; ci < _tree.length; ci++) ...[
            if (ci > 0) const SizedBox(height: 14),
            _buildCategory(ci),
          ],
        ],
      ),
    );
  }

  Widget _buildCategory(int ci) {
    final cat = _tree[ci];
    final open = _expanded.contains(ci);
    final color = _levelColor(cat.level);

    return ClayCard(
      radius: AppTheme.radiusCard,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Category header
          GestureDetector(
            onTap: () => setState(() => open ? _expanded.remove(ci) : _expanded.add(ci)),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
              child: Row(
                children: [
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
                          cat.title,
                          style: AppTheme.heading(size: 22, weight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '掌握 ${cat.count}',
                          style: AppTheme.label(size: 13, color: AppTheme.muted),
                        ),
                      ],
                    ),
                  ),
                  _LevelPill(cat.level),
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
          // Items
          if (open)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                children: [
                  for (final item in cat.items)
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
      onTap: () => context.push(AppRoutes.modelDetail),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(top: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.canvas,
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
