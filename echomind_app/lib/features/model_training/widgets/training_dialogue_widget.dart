import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/providers/model_training_provider.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';

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
          duration: const Duration(milliseconds: 220),
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
    final extraCount =
        (state.isSending ? 1 : 0) + (hasNextStep ? 1 : 0) + (hasResult ? 1 : 0);

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      itemCount: state.messages.length + extraCount,
      itemBuilder: (_, index) {
        if (index < state.messages.length) {
          final message = state.messages[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildBubble(
              text: message.content,
              isAi: message.role == 'assistant',
            ),
          );
        }

        final offset = index - state.messages.length;

        if (state.isSending && offset == 0) {
          return const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: _TypingIndicator(),
          );
        }

        final nextOffset = state.isSending ? 1 : 0;
        if (hasNextStep && offset == nextOffset) {
          return _buildNextStepButton(state.nextStepHint);
        }

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

  Widget _buildBubble({
    required String text,
    required bool isAi,
  }) {
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

  Widget _buildNextStepButton(NextStepHint? hint) {
    final label = hint == null ? '进入下一步' : '进入下一步：${hint.stepName}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        width: double.infinity,
        height: 46,
        decoration: BoxDecoration(
          gradient: AppTheme.gradientGreen,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          boxShadow: AppTheme.shadowClayButton,
        ),
        child: ElevatedButton(
          onPressed: () => ref.read(trainingProvider.notifier).nextStep(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
            elevation: 0,
          ),
          child: Text(
            label,
            style: AppTheme.body(
                size: 15, weight: FontWeight.w800, color: Colors.white),
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
            Text('AI 正在思考...',
                style: AppTheme.body(
                    size: 13, weight: FontWeight.w700, color: AppTheme.muted)),
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
    final mastery = result.masteryUpdate;
    final passed = result.stepsPassed.length;
    final total = result.stepsCompleted.length;
    final levelUp = mastery.newLevel > mastery.previousLevel;

    return ClayCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('训练完成',
              style: AppTheme.heading(size: 20, weight: FontWeight.w900)),
          const SizedBox(height: 10),
          Row(
            children: [
              Text('掌握度', style: AppTheme.label(size: 12)),
              const SizedBox(width: 8),
              Text('L${mastery.previousLevel}',
                  style: AppTheme.body(
                      size: 14,
                      weight: FontWeight.w700,
                      color: AppTheme.muted)),
              Icon(
                levelUp ? Icons.arrow_upward : Icons.arrow_forward,
                size: 14,
                color: levelUp ? AppTheme.success : AppTheme.muted,
              ),
              Text(
                'L${mastery.newLevel}',
                style: AppTheme.body(
                  size: 14,
                  weight: FontWeight.w800,
                  color: levelUp ? AppTheme.success : AppTheme.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('步骤通过：$passed / $total', style: AppTheme.label(size: 12)),
          if (result.aiSummary.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.canvas,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Text(
                result.aiSummary,
                style: AppTheme.body(
                    size: 13, weight: FontWeight.w600, color: AppTheme.muted),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
