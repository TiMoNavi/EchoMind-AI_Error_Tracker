import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/app/app_routes.dart';
import 'package:echomind_app/models/model_item.dart';
import 'package:echomind_app/providers/model_tree_provider.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';

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

class ModelTreeWidget extends ConsumerStatefulWidget {
  const ModelTreeWidget({super.key});

  @override
  ConsumerState<ModelTreeWidget> createState() => _ModelTreeWidgetState();
}

class _ModelTreeWidgetState extends ConsumerState<ModelTreeWidget> {
  final _expanded = <int>{0};

  static const _fallbackTree = [
    _FallbackCategory(
      title: '受力分析模型',
      level: 4,
      count: '4/5',
      items: [
        _FallbackItem(title: '整体法与隔离法', level: 5),
        _FallbackItem(title: '共点力平衡', level: 4),
        _FallbackItem(title: '斜面体模型', level: 3),
        _FallbackItem(title: '连接体模型', level: 4),
        _FallbackItem(title: '板块运动', level: 2),
      ],
    ),
    _FallbackCategory(
      title: '运动学模型',
      level: 3,
      count: '2/4',
      items: [
        _FallbackItem(title: '匀变速直线运动', level: 4),
        _FallbackItem(title: '抛体运动', level: 3),
        _FallbackItem(title: '圆周运动', level: 2),
        _FallbackItem(title: '追及相遇', level: 1),
      ],
    ),
    _FallbackCategory(
      title: '能量守恒模型',
      level: 1,
      count: '1/3',
      items: [
        _FallbackItem(title: '动能定理应用', level: 2),
        _FallbackItem(title: '机械能守恒', level: 1),
        _FallbackItem(title: '功能关系', level: 0),
      ],
    ),
    _FallbackCategory(
      title: '电磁学模型',
      level: 0,
      count: '0/3',
      items: [
        _FallbackItem(title: '带电粒子在电场中运动', level: 1),
        _FallbackItem(title: '带电粒子在磁场中运动', level: 0),
        _FallbackItem(title: '电磁感应综合', level: 0),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final asyncTree = ref.watch(modelTreeProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: asyncTree.when(
        loading: () => _buildFallbackTree(),
        error: (_, __) => _buildFallbackTree(),
        data: (chapters) {
          if (chapters.isEmpty) return _buildFallbackTree();
          return _buildApiTree(chapters);
        },
      ),
    );
  }

  Widget _buildApiTree(List<ModelChapterNode> chapters) {
    final categories =
        List<_ApiCategory>.generate(chapters.length, (chapterIdx) {
      final chapter = chapters[chapterIdx];
      final leaves = <_ApiLeaf>[];

      for (final section in chapter.sections) {
        for (final item in section.items) {
          final level = _guessLevel(
              '${chapter.chapter}|${section.section}|${item.id}|${item.name}');
          leaves.add(
            _ApiLeaf(
              id: item.id.trim().isEmpty ? 'demo' : item.id,
              title: item.name,
              level: level,
            ),
          );
        }
      }

      final total = leaves.length;
      final mastered = leaves.where((e) => e.level >= 3).length;
      final chapterLevel = total == 0
          ? 0
          : (leaves.fold<int>(0, (sum, e) => sum + e.level) / total)
              .round()
              .clamp(0, 5);

      return _ApiCategory(
        title: chapter.chapter,
        level: chapterLevel,
        count: '$mastered/$total',
        items: leaves,
      );
    });

    return Column(
      children: [
        for (var i = 0; i < categories.length; i++) ...[
          if (i > 0) const SizedBox(height: 14),
          _buildApiCategory(i, categories[i]),
        ],
      ],
    );
  }

  Widget _buildApiCategory(int index, _ApiCategory category) {
    final open = _expanded.contains(index);
    final color = _levelColor(category.level);

    return ClayCard(
      radius: AppTheme.radiusCard,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() {
              if (open) {
                _expanded.remove(index);
              } else {
                _expanded.add(index);
              }
            }),
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
                          category.title,
                          style: AppTheme.heading(
                              size: 22, weight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '掌握 ${category.count}',
                          style:
                              AppTheme.label(size: 13, color: AppTheme.muted),
                        ),
                      ],
                    ),
                  ),
                  _LevelPill(category.level),
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
          if (open)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                children: [
                  for (final item in category.items) _buildApiItem(item),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildApiItem(_ApiLeaf item) {
    final color = _levelColor(item.level);

    return GestureDetector(
      onTap: () => context.push(AppRoutes.modelDetailPath(item.id)),
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
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                item.title,
                style: AppTheme.body(size: 16, weight: FontWeight.w600),
              ),
            ),
            _LevelPill(item.level),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackTree() {
    return Column(
      children: [
        for (var i = 0; i < _fallbackTree.length; i++) ...[
          if (i > 0) const SizedBox(height: 14),
          _buildFallbackCategory(i, _fallbackTree[i]),
        ],
      ],
    );
  }

  Widget _buildFallbackCategory(int index, _FallbackCategory category) {
    final open = _expanded.contains(index);
    final color = _levelColor(category.level);

    return ClayCard(
      radius: AppTheme.radiusCard,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() {
              if (open) {
                _expanded.remove(index);
              } else {
                _expanded.add(index);
              }
            }),
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
                          category.title,
                          style: AppTheme.heading(
                              size: 22, weight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '掌握 ${category.count}',
                          style:
                              AppTheme.label(size: 13, color: AppTheme.muted),
                        ),
                      ],
                    ),
                  ),
                  _LevelPill(category.level),
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
          if (open)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                children: [
                  for (final item in category.items) _buildFallbackItem(item),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFallbackItem(_FallbackItem item) {
    final color = _levelColor(item.level);

    return GestureDetector(
      onTap: () => context.push(AppRoutes.modelDetailPath('demo')),
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
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                item.title,
                style: AppTheme.body(size: 16, weight: FontWeight.w600),
              ),
            ),
            _LevelPill(item.level),
          ],
        ),
      ),
    );
  }

  int _guessLevel(String seed) {
    var hash = 0;
    for (final unit in seed.codeUnits) {
      hash = (hash * 131 + unit) & 0x7fffffff;
    }
    return hash % 6;
  }
}

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

class _ApiCategory {
  final String title;
  final int level;
  final String count;
  final List<_ApiLeaf> items;

  const _ApiCategory({
    required this.title,
    required this.level,
    required this.count,
    required this.items,
  });
}

class _ApiLeaf {
  final String id;
  final String title;
  final int level;

  const _ApiLeaf({
    required this.id,
    required this.title,
    required this.level,
  });
}

class _FallbackCategory {
  final String title;
  final int level;
  final String count;
  final List<_FallbackItem> items;

  const _FallbackCategory({
    required this.title,
    required this.level,
    required this.count,
    required this.items,
  });
}

class _FallbackItem {
  final String title;
  final int level;

  const _FallbackItem({
    required this.title,
    required this.level,
  });
}
