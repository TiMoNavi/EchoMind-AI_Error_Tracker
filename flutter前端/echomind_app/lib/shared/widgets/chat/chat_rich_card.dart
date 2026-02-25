import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/models/chat_message.dart';

/// Renders rich content cards embedded in the chat stream.
/// Uses [ChatMessage.metadata] to drive content.
class ChatRichCard extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onAction;

  const ChatRichCard({
    super.key,
    required this.message,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return switch (message.type) {
      MessageContentType.questionRef => _buildQuestionRef(),
      MessageContentType.conclusion => _buildConclusion(),
      MessageContentType.stepSummary => _buildStepSummary(),
      MessageContentType.table => _buildTable(),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _buildQuestionRef() {
    final title = message.metadata?['title'] as String? ?? '';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Row(
        children: [
          const Icon(Icons.description_outlined, size: 16, color: AppTheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '引用题目：$title',
              style: const TextStyle(fontSize: 13, color: AppTheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConclusion() {
    final title = message.metadata?['title'] as String? ?? '诊断结论';
    final desc = message.metadata?['description'] as String? ?? '';
    final actionLabel = message.metadata?['actionLabel'] as String?;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(
            fontSize: 15, fontWeight: FontWeight.w600,
          )),
          const SizedBox(height: 8),
          Text(desc, style: const TextStyle(
            fontSize: 13, color: AppTheme.textSecondary,
          )),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  elevation: 0,
                ),
                child: Text(actionLabel, style: const TextStyle(
                  fontWeight: FontWeight.w600,
                )),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStepSummary() {
    final step = message.metadata?['step'] as String? ?? '';
    final summary = message.metadata?['summary'] as String? ?? '';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(step, style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
            )),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('已通过', style: TextStyle(
                fontSize: 10,
                color: AppTheme.primary,
                fontWeight: FontWeight.w600,
              )),
            ),
          ]),
          const SizedBox(height: 4),
          Text(summary, style: const TextStyle(
            fontSize: 13, color: AppTheme.textSecondary,
          )),
        ],
      ),
    );
  }

  Widget _buildTable() {
    final title = message.metadata?['title'] as String? ?? '';
    final headers = (message.metadata?['headers'] as List?)
        ?.cast<String>() ?? [];
    final rows = (message.metadata?['rows'] as List?)
        ?.cast<List>() ?? [];
    final highlightCol = message.metadata?['highlightCol'] as int?;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty) ...[
            Text(title, style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600,
            )),
            const SizedBox(height: 10),
          ],
          Table(
            border: TableBorder.all(
              color: AppTheme.divider, width: 0.5,
            ),
            children: [
              _tableRow(headers, isHeader: true),
              for (final row in rows)
                _tableRow(
                  row.cast<String>(),
                  highlightCol: highlightCol,
                ),
            ],
          ),
        ],
      ),
    );
  }

  static TableRow _tableRow(
    List<String> cells, {
    bool isHeader = false,
    int? highlightCol,
  }) {
    return TableRow(
      decoration: isHeader
          ? const BoxDecoration(color: AppTheme.background)
          : null,
      children: [
        for (int i = 0; i < cells.length; i++)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              cells[i],
              style: TextStyle(
                fontSize: 12,
                fontWeight: isHeader || i == 0 || i == highlightCol
                    ? FontWeight.w600
                    : FontWeight.normal,
                color: i == highlightCol
                    ? AppTheme.primary
                    : null,
              ),
            ),
          ),
      ],
    );
  }
}