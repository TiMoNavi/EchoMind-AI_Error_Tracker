import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';
import 'package:google_fonts/google_fonts.dart';

class TargetScoreCardWidget extends StatelessWidget {
  final int targetScore;
  final String subject;
  final String strategy;

  const TargetScoreCardWidget({
    super.key,
    this.targetScore = 70,
    this.subject = '物理',
    this.strategy = '卷面策略: 选择题最多错2个, 大题前两道拿满',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClayCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('目标分数', style: AppTheme.label(size: 13)),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$targetScore',
                          style: GoogleFonts.nunito(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.accent,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text('分 ($subject)', style: AppTheme.label(size: 13)),
                      ],
                    ),
                  ],
                ),
                TextButton(onPressed: () {}, child: Text('修改', style: AppTheme.label(size: 13, color: AppTheme.accent))),
              ],
            ),
            const SizedBox(height: 8),
            Text(strategy, style: AppTheme.body(size: 13, color: AppTheme.muted), maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
