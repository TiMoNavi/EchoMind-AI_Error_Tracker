import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/providers/question_detail_provider.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';

class QuestionSourceWidget extends ConsumerWidget {
  final String questionId;

  const QuestionSourceWidget({super.key, required this.questionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(questionDetailProvider(questionId));

    final view = detail.when(
      loading: () => const _SourceView(
        source: '正在加载',
        questionNo: '--',
        fullScore: '--',
        attitude: '待评估',
      ),
      error: (_, __) => const _SourceView(
        source: '2025天津模拟(一)',
        questionNo: '选择题 第5题',
        fullScore: '3 分',
        attitude: 'MUST',
      ),
      data: (d) => _SourceView(
        source: _textOr(d.source, '2025天津模拟(一)'),
        questionNo: _textOr(d.questionNumber, '选择题 第5题'),
        fullScore: _normalizeScore(d.score),
        attitude: _attitudeTag(d.attitude),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClayCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _row('来源卷子', view.source),
            const SizedBox(height: 10),
            _row('题号', view.questionNo),
            const SizedBox(height: 10),
            _row('满分', view.fullScore),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('态度', style: AppTheme.label(size: 13)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _attitudeColor(view.attitude),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Text(
                    view.attitude,
                    style: AppTheme.label(size: 11, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTheme.label(size: 13)),
        Flexible(
          child: Text(
            value,
            style: AppTheme.body(size: 13, weight: FontWeight.w700),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  static String _textOr(String? raw, String fallback) {
    final text = raw?.trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  static String _normalizeScore(String? raw) {
    final text = raw?.trim() ?? '';
    if (text.isEmpty) return '3 分';
    return text.contains('分') ? text : '$text 分';
  }

  static String _attitudeTag(String? raw) {
    final text = raw?.trim() ?? '';
    if (text.isEmpty) return 'MUST';

    if (text.contains('粗心') || text.contains('急躁') || text.contains('must')) {
      return 'MUST';
    }
    if (text.contains('建议') || text.contains('warn')) return 'WARN';
    return text;
  }

  Color _attitudeColor(String tag) {
    if (tag == 'MUST') return AppTheme.danger;
    if (tag == 'WARN') return AppTheme.warning;
    return AppTheme.accent;
  }
}

class _SourceView {
  final String source;
  final String questionNo;
  final String fullScore;
  final String attitude;

  const _SourceView({
    required this.source,
    required this.questionNo,
    required this.fullScore,
    required this.attitude,
  });
}
