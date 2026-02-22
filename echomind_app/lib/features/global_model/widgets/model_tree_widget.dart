import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/app/app_routes.dart';
import 'package:echomind_app/providers/model_tree_provider.dart';

Color _levelColor(int level) => switch (level) {
  0 => const Color(0xFFFF3B30),
  1 => const Color(0xFFFF9500),
  2 => const Color(0xFFFFCC00),
  3 => const Color(0xFF007AFF),
  4 => const Color(0xFF34C759),
  _ => const Color(0xFF00875A),
};

class ModelTreeWidget extends ConsumerStatefulWidget {
  const ModelTreeWidget({super.key});

  @override
  ConsumerState<ModelTreeWidget> createState() => _ModelTreeWidgetState();
}

class _ModelTreeWidgetState extends ConsumerState<ModelTreeWidget> {
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
    // Prefetch API data; will be used when backend format is finalized
    // ignore: unused_local_variable
    final apiTree = ref.watch(modelTreeProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          for (var i = 0; i < _tree.length; i++) _buildCategory(i),
        ],
      ),
    );
  }

  Widget _buildCategory(int ci) {
    final cat = _tree[ci];
    final open = _expanded.contains(ci);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
      child: Column(children: [
        GestureDetector(
          onTap: () => setState(() => open ? _expanded.remove(ci) : _expanded.add(ci)),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              Icon(open ? Icons.expand_more : Icons.chevron_right, size: 20, color: AppTheme.textSecondary),
              const SizedBox(width: 6),
              Expanded(child: Text(cat.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
              Text(cat.count, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              const SizedBox(width: 8),
              _LevelBadge(cat.level),
            ]),
          ),
        ),
        if (open)
          for (final item in cat.items)
            GestureDetector(
              onTap: () => context.push(AppRoutes.modelDetail),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(40, 8, 14, 8),
                child: Row(children: [
                  Container(width: 6, height: 6, decoration: BoxDecoration(color: _levelColor(item.level), shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(item.title, style: const TextStyle(fontSize: 13))),
                  _LevelBadge(item.level),
                ]),
              ),
            ),
      ]),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  final int level;
  const _LevelBadge(this.level);

  @override
  Widget build(BuildContext context) {
    final color = _levelColor(level);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(4)),
      child: Text('L$level', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}
