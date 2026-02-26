import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/providers/ai_diagnosis_provider.dart';
import 'package:echomind_app/features/ai_diagnosis/widgets/top_frame_widget.dart';
import 'package:echomind_app/features/ai_diagnosis/widgets/main_content_widget.dart';
import 'package:echomind_app/features/ai_diagnosis/widgets/action_overlay_widget.dart';

class AiDiagnosisPage extends ConsumerStatefulWidget {
  final String? questionId;
  const AiDiagnosisPage({super.key, this.questionId});

  @override
  ConsumerState<AiDiagnosisPage> createState() => _AiDiagnosisPageState();
}

class _AiDiagnosisPageState extends ConsumerState<AiDiagnosisPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _initSession());
  }

  Future<void> _initSession() async {
    final notifier = ref.read(diagnosisProvider.notifier);
    if (widget.questionId != null) {
      // 从题目详情页进入：开始新会话
      await notifier.startSession(questionId: widget.questionId!);
    } else {
      // 从菜单进入：恢复活跃会话
      await notifier.fetchActiveSession();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(diagnosisProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            const TopFrameWidget(),
            Expanded(child: _buildBody(state)),
            if (state.isActive) const ActionOverlayWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(DiagnosisState state) {
    if (state.isLoading && state.messages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null && !state.hasSession) {
      return _buildError(state.errorMessage!);
    }

    if (!state.hasSession) {
      return _buildEmpty();
    }

    return const MainContentWidget();
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.psychology_outlined,
                size: 64, color: AppTheme.textSecondary),
            const SizedBox(height: 16),
            const Text('暂无活跃的诊断会话',
                style:
                    TextStyle(fontSize: 16, color: AppTheme.textSecondary)),
            const SizedBox(height: 8),
            const Text('从错题详情页点击「AI 诊断」开始',
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                size: 48, color: AppTheme.danger),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _initSession,
              child: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }
}
