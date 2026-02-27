import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/app/app_routes.dart';
import 'package:echomind_app/providers/ai_diagnosis_provider.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';

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
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(diagnosisProvider);
    _scrollToBottom();

    final extraCount =
        (state.isSending ? 1 : 0) + (state.diagnosisResult != null ? 1 : 0);

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      itemCount: state.messages.length + extraCount,
      itemBuilder: (_, index) {
        if (index < state.messages.length) {
          final msg = state.messages[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildBubble(
              text: msg.content,
              isAi: msg.role == 'assistant' || msg.role == 'system',
            ),
          );
        }

        if (state.isSending && index == state.messages.length) {
          return const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: _TypingIndicator(),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: _DiagnosisResultCard(result: state.diagnosisResult!),
        );
      },
    );
  }

  Widget _buildBubble({required String text, required bool isAi}) {
    return Align(
      alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isAi ? Colors.white.withValues(alpha: 0.82) : null,
            gradient: isAi ? null : AppTheme.gradientPrimary,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            boxShadow:
                isAi ? AppTheme.shadowClayPressed : AppTheme.shadowClayButton,
          ),
          child: Text(
            text,
            style: AppTheme.body(
              size: 14,
              weight: FontWeight.w600,
              color: isAi ? AppTheme.foreground : Colors.white,
            ),
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
      child: ClayCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 8),
            Text('智能诊断正在思考...',
                style: AppTheme.body(
                    size: 13, weight: FontWeight.w700, color: AppTheme.muted)),
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
    return ClayCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('诊断结论',
              style: AppTheme.heading(size: 20, weight: FontWeight.w900)),
          const SizedBox(height: 10),
          _buildFourLayer(),
          const SizedBox(height: 10),
          _buildEvidence(),
          if (result.nextAction.message.trim().isNotEmpty) ...[
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
        Text('四层诊断', style: AppTheme.body(size: 14, weight: FontWeight.w800)),
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
        if (fl.bottleneckLayer.trim().isNotEmpty ||
            fl.bottleneckDetail.trim().isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            '瓶颈：${fl.bottleneckLayer} ${fl.bottleneckDetail}'.trim(),
            style: AppTheme.body(
                size: 12, weight: FontWeight.w700, color: AppTheme.danger),
          ),
        ],
      ],
    );
  }

  Widget _layerChip(String label, String status) {
    final normalized = status.trim().toLowerCase();
    final color = switch (normalized) {
      'pass' || 'passed' => AppTheme.success,
      'fail' || 'failed' => AppTheme.danger,
      _ => AppTheme.warning,
    };

    final statusText = switch (normalized) {
      'pass' || 'passed' => '通过',
      'fail' || 'failed' => '未通过',
      _ => status.trim().isEmpty ? '待判定' : status,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Text(
        '$label：$statusText',
        style: AppTheme.label(size: 11, color: color),
      ),
    );
  }

  Widget _buildEvidence() {
    final e = result.evidence5w;

    if (e.whatDescription.trim().isEmpty &&
        e.aiExplanation.trim().isEmpty &&
        e.confidence.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('错因分析', style: AppTheme.body(size: 14, weight: FontWeight.w800)),
        const SizedBox(height: 6),
        if (e.whatDescription.trim().isNotEmpty)
          _infoRow('问题', e.whatDescription),
        if (e.whenStage.trim().isNotEmpty) _infoRow('阶段', e.whenStage),
        if (e.rootCauseId.trim().isNotEmpty) _infoRow('根因ID', e.rootCauseId),
        if (e.aiExplanation.trim().isNotEmpty) _infoRow('解释', e.aiExplanation),
        if (e.confidence.trim().isNotEmpty) _infoRow('置信度', e.confidence),
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
            width: 52,
            child: Text('$label：', style: AppTheme.label(size: 11)),
          ),
          Expanded(
              child: Text(value,
                  style: AppTheme.body(size: 12, weight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _buildNextAction(BuildContext context) {
    final action = result.nextAction;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            action.message,
            style: AppTheme.body(
                size: 13, weight: FontWeight.w700, color: AppTheme.accent),
          ),
          if (action.type == 'model_training' &&
              action.targetId.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 38,
              child: ElevatedButton(
                onPressed: () {
                  context.push(AppRoutes.modelTrainingPath(
                    modelId: action.targetId,
                    source: 'error_diagnosis',
                  ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  '开始针对训练',
                  style: AppTheme.body(
                      size: 13, weight: FontWeight.w800, color: Colors.white),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
