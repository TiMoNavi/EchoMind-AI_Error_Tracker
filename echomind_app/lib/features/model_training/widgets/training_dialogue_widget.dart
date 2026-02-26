import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/providers/model_training_provider.dart';

class TrainingDialogueWidget extends ConsumerStatefulWidget {
  const TrainingDialogueWidget({super.key});

  @override
  ConsumerState<TrainingDialogueWidget> createState() =>
      _TrainingDialogueWidgetState();
}

class _TrainingDialogueWidgetState
    extends ConsumerState<TrainingDialogueWidget> {
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
    final state = ref.watch(trainingProvider);
    _scrollToBottom();

    final hasNextStep = state.canAdvance;
    final hasResult = state.trainingResult != null;
    final extraCount = (state.isSending ? 1 : 0) +
        (hasNextStep ? 1 : 0) +
        (hasResult ? 1 : 0);

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: state.messages.length + extraCount,
      itemBuilder: (_, i) {
        // 消息气泡
        if (i < state.messages.length) {
          final msg = state.messages[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _bubble(msg.content, msg.role == 'assistant'),
          );
        }

        final offset = i - state.messages.length;

        // 发送中指示器
        if (state.isSending && offset == 0) {
          return const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: _TypingIndicator(),
          );
        }

        // "进入下一步"按钮
        final nextOffset = state.isSending ? 1 : 0;
        if (hasNextStep && offset == nextOffset) {
          return _buildNextStepButton();
        }

        // 训练结果卡片
        if (hasResult) {
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _TrainingResultCard(result: state.trainingResult!),
          );
        }

        return const SizedBox.shrink();
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

  Widget _buildNextStepButton() {
    final hint = ref.read(trainingProvider).nextStepHint;
    final label = hint != null ? '进入下一步：${hint.stepName}' : '进入下一步';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            onPressed: () {
              ref.read(trainingProvider.notifier).nextStep();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: Text(label,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600)),
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
                style:
                    TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _TrainingResultCard extends StatelessWidget {
  final TrainingResult result;
  const _TrainingResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final mu = result.masteryUpdate;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('训练完成',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          _buildMasteryRow(mu),
          const SizedBox(height: 8),
          _buildStepsRow(),
          if (result.aiSummary.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(result.aiSummary,
                style: const TextStyle(
                    fontSize: 13, color: AppTheme.textSecondary)),
          ],
        ],
      ),
    );
  }

  Widget _buildMasteryRow(MasteryUpdate mu) {
    final levelUp = mu.newLevel > mu.previousLevel;
    return Row(
      children: [
        const Text('掌握度：',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        Text('L${mu.previousLevel}',
            style: const TextStyle(
                fontSize: 13, color: AppTheme.textSecondary)),
        Icon(levelUp ? Icons.arrow_upward : Icons.arrow_forward,
            size: 14,
            color: levelUp ? AppTheme.success : AppTheme.textSecondary),
        Text('L${mu.newLevel}',
            style: TextStyle(
              fontSize: 13,
              color: levelUp ? AppTheme.success : AppTheme.textSecondary,
              fontWeight: levelUp ? FontWeight.w600 : FontWeight.normal,
            )),
      ],
    );
  }

  Widget _buildStepsRow() {
    final passed = result.stepsPassed.length;
    final total = result.stepsCompleted.length;
    return Text('完成步骤：$passed / $total 通过',
        style: const TextStyle(
            fontSize: 12, color: AppTheme.textSecondary));
  }
}
