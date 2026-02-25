import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/app/app_routes.dart';

class ScorePathTableWidget extends StatelessWidget {
  final List<ScorePathRow> rows;

  const ScorePathTableWidget({
    super.key,
    this.rows = const [
      ScorePathRow(id: '第5题', attitude: 'MUST', action: '板块运动训练', score: '+3'),
      ScorePathRow(id: '第7题', attitude: 'MUST', action: '电场综合训练', score: '+3'),
      ScorePathRow(id: '大题1', attitude: 'MUST', action: '力学大题训练', score: '+4'),
      ScorePathRow(id: '大题2', attitude: 'TRY', action: '前两问拿分', score: '+2'),
      ScorePathRow(id: '大题3', attitude: 'SKIP', action: '暂不投入', score: '--'),
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('提分路径', style: AppTheme.heading(size: 18)),
          const SizedBox(height: 12),
          ClayCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _headerRow(),
                const SizedBox(height: 8),
                for (int i = 0; i < rows.length; i++) ...[
                  if (i > 0) const SizedBox(height: 2),
                  _buildRow(context, rows[i]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _headerRow() {
    return Row(
      children: [
        Expanded(flex: 2, child: Text('题号', style: AppTheme.label(size: 11))),
        Expanded(flex: 2, child: Text('现状', style: AppTheme.label(size: 11))),
        Expanded(flex: 3, child: Text('动作', style: AppTheme.label(size: 11))),
        Expanded(flex: 2, child: Text('预计提分', textAlign: TextAlign.right,
            style: AppTheme.label(size: 11))),
      ],
    );
  }

  Widget _buildRow(BuildContext context, ScorePathRow row) {
    final isSkip = row.attitude == 'SKIP';
    final isMust = row.attitude == 'MUST';

    return GestureDetector(
      onTap: isSkip ? null : () => context.push(AppRoutes.questionAggregate),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(flex: 2, child: Text(row.id,
                style: AppTheme.body(
                  size: 13,
                  weight: FontWeight.w600,
                  color: isSkip ? AppTheme.muted : AppTheme.foreground,
                ))),
            Expanded(flex: 2, child: _attitudeBadge(row.attitude)),
            Expanded(flex: 3, child: Text(row.action,
                style: AppTheme.body(
                  size: 12,
                  color: isSkip ? AppTheme.muted : AppTheme.foreground,
                ))),
            Expanded(flex: 2, child: Text(row.score, textAlign: TextAlign.right,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isMust ? AppTheme.accent : AppTheme.muted,
                ))),
          ],
        ),
      ),
    );
  }

  static Widget _attitudeBadge(String label) {
    Color bg;
    switch (label) {
      case 'MUST':
        bg = AppTheme.danger;
        break;
      case 'TRY':
        bg = AppTheme.warning;
        break;
      default:
        bg = AppTheme.muted;
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
        child: Text(label,
            style: GoogleFonts.nunito(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            )),
      ),
    );
  }
}

class ScorePathRow {
  final String id;
  final String attitude;
  final String action;
  final String score;

  const ScorePathRow({
    required this.id,
    required this.attitude,
    required this.action,
    required this.score,
  });
}