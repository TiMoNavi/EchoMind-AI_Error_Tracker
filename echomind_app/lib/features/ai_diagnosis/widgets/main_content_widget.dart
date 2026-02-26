import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/app/app_routes.dart';
import 'package:echomind_app/providers/ai_diagnosis_provider.dart';

class MainContentWidget extends ConsumerStatefulWidget {
  const MainContentWidget({super.key});

  @override
  ConsumerState<MainContentWidget> createState() => _MainContentWidgetState();
}

class _MainContentWidgetState extends ConsumerState<MainContentWidget> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(diagnosisProvider);
    _scrollToBottom();

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: state.messages.length +
          (state.isSending ? 1 : 0) +
          (state.diagnosisResult != null ? 1 : 0),
      itemBuilder: (_, i) {
        // 消息气泡
        if (i < state.messages.length) {
          final msg = state.messages[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _bubble(msg.content, msg.role == 'assistant'),
          );
        }
        // 发送中指示器
        if (state.isSending && i == state.messages.length) {
          return const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: _TypingIndicator(),
          );
        }
        // 诊断结论卡片
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: _DiagnosisResultCard(result: state.diagnosisResult!),
        );
      },
    );
  }

  static Widget _bubble(String text, bool isAi) {
    return Align(
      alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isAi ? AppTheme.surface : AppTheme.primary,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: isAi ? null : Colors.white,
          ),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 8),
            Text('AI 思考中...',
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _DiagnosisResultCard extends StatelessWidget {
  final DiagnosisResult result;
  const _DiagnosisResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('诊断结论',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          // 四层诊断
          _buildFourLayer(),
          const SizedBox(height: 10),
          // 5W 证据
          _buildEvidence(),
          // 下一步建议
          if (result.nextAction.message.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildNextAction(context),
          ],
        ],
      ),
    );
  }

  Widget _buildFourLayer() {
    final fl = result.fourLayer;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('四层诊断',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            _layerChip('建模', fl.modeling),
            _layerChip('公式', fl.equation),
            _layerChip('执行', fl.execution),
          ],
        ),
        if (fl.bottleneckDetail.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text('瓶颈：${fl.bottleneckDetail}',
              style: const TextStyle(fontSize: 12, color: AppTheme.danger)),
        ],
      ],
    );
  }

  Widget _layerChip(String label, String status) {
    final color = switch (status) {
      'pass' => AppTheme.success,
      'fail' => AppTheme.danger,
      _ => AppTheme.textSecondary,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text('$label: $status',
          style: TextStyle(fontSize: 11, color: color)),
    );
  }

  Widget _buildEvidence() {
    final e = result.evidence5w;
    if (e.whatDescription.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('错因分析',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        if (e.whatDescription.isNotEmpty)
          _infoRow('问题', e.whatDescription),
        if (e.aiExplanation.isNotEmpty)
          _infoRow('解释', e.aiExplanation),
        if (e.confidence.isNotEmpty)
          _infoRow('置信度', e.confidence),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 56,
            child: Text('$label：',
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.textSecondary)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildNextAction(BuildContext context) {
    final na = result.nextAction;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(na.message,
              style: const TextStyle(fontSize: 13, color: AppTheme.primary)),
          if (na.type == 'model_training' && na.targetId.isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 36,
              child: ElevatedButton(
                onPressed: () {
                  context.push('${AppRoutes.modelTraining}?modelId=${na.targetId}&source=error_diagnosis');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: const Text('开始训练',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}