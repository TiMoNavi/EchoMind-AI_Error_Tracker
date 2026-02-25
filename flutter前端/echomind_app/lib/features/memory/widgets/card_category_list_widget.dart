import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';

class CardCategoryListWidget extends StatelessWidget {
  final List<CardCategory> categories;

  const CardCategoryListWidget({
    super.key,
    this.categories = const [
      CardCategory(tag: '识别', tagBg: Color(0xFF1C1C1E), tagFg: Colors.white, name: '识别卡', desc: '8张 · 来自模型训练 Step1', review: '3张待复习'),
      CardCategory(tag: '决策', tagBg: Color(0xFF48484A), tagFg: Colors.white, name: '决策卡', desc: '6张 · 来自模型训练 Step2', review: '2张待复习'),
      CardCategory(tag: '步骤', tagBg: Color(0xFF8E8E93), tagFg: Colors.white, name: '步骤卡', desc: '5张 · 来自模型训练 Step3', review: '1张待复习'),
      CardCategory(tag: '陷阱', tagBg: Color(0xFF3A3A3C), tagFg: Colors.white, name: '陷阱卡', desc: '4张 · 来自模型训练 Step4', review: '0'),
      CardCategory(tag: '公式', tagBg: Color(0xFF007AFF), tagFg: Colors.white, name: '公式卡', desc: '10张 · 通用', review: '4张待复习'),
      CardCategory(tag: '概念', tagBg: Color(0xFFBBDEFB), tagFg: Color(0xFF1565C0), name: '概念卡', desc: '9张 · 来自知识点学习', review: '2张待复习'),
      CardCategory(tag: '条件', tagBg: Color(0xFFE3F2FD), tagFg: Color(0xFF1976D2), name: '条件卡', desc: '4张 · 来自知识点学习', review: '0'),
      CardCategory(tag: '辨析', tagBg: Color(0xFFF5F9FF), tagFg: Color(0xFF2196F3), name: '辨析卡', desc: '2张 · 来自易混对比', review: '0'),
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('卡片分类', style: AppTheme.heading(size: 18)),
              ),
              GestureDetector(
                onTap: () {},
                child: Text('管理', style: AppTheme.label(size: 14, color: AppTheme.accent)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Column(
            children: [
              for (var i = 0; i < categories.length; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                _CategoryRow(c: categories[i]),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final CardCategory c;
  const _CategoryRow({required this.c});

  @override
  Widget build(BuildContext context) {
    return ClayCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [c.tagBg.withValues(alpha: 0.8), c.tagBg],
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              boxShadow: [
                BoxShadow(
                  color: c.tagBg.withValues(alpha: 0.3),
                  blurRadius: 8, offset: const Offset(0, 3)),
              ],
            ),
            alignment: Alignment.center,
            child: Text(c.tag,
                style: AppTheme.label(size: 11, color: c.tagFg)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.name, style: AppTheme.body(size: 15, weight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(c.desc, style: AppTheme.label(size: 12)),
              ],
            ),
          ),
          Text(c.review, style: AppTheme.label(size: 13)),
        ],
      ),
    );
  }
}

class CardCategory {
  final String tag;
  final Color tagBg;
  final Color tagFg;
  final String name;
  final String desc;
  final String review;

  const CardCategory({
    required this.tag,
    required this.tagBg,
    required this.tagFg,
    required this.name,
    required this.desc,
    required this.review,
  });
}
