import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/providers/ai_diagnosis_provider.dart';

class ActionOverlayWidget extends ConsumerStatefulWidget {
  const ActionOverlayWidget({super.key});

  @override
  ConsumerState<ActionOverlayWidget> createState() =>
      _ActionOverlayWidgetState();
}

class _ActionOverlayWidgetState extends ConsumerState<ActionOverlayWidget> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    ref.read(diagnosisProvider.notifier).sendMessage(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(diagnosisProvider);
    final canSend = state.canSend;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.divider, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: canSend,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: canSend ? '输入你的回答...' : '对话已结束',
                  hintStyle: const TextStyle(
                      fontSize: 14, color: AppTheme.textSecondary),
                  filled: true,
                  fillColor: AppTheme.background,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _buildSendButton(canSend),
          ],
        ),
      ),
    );
  }

  Widget _buildSendButton(bool enabled) {
    return GestureDetector(
      onTap: enabled ? _send : null,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: enabled ? AppTheme.primary : AppTheme.textSecondary,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.send, size: 18, color: Colors.white),
      ),
    );
  }
}