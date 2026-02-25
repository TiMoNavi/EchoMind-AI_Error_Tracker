import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/providers/ai_diagnosis_provider.dart';
import 'package:echomind_app/features/ai_diagnosis/widgets/top_frame_widget.dart';
import 'package:echomind_app/features/ai_diagnosis/widgets/main_content_widget.dart';
import 'package:echomind_app/features/ai_diagnosis/widgets/action_overlay_widget.dart';

class AiDiagnosisPage extends ConsumerWidget {
  const AiDiagnosisPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(aiDiagnosisProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: session.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => _buildDemoContent(),
          data: (data) => data == null ? _buildDemoContent() : _buildDemoContent(),
        ),
      ),
    );
  }

  /// API 未就绪时显示 demo 内容（原硬编码 UI）
  Widget _buildDemoContent() {
    return const Column(
      children: [
        TopFrameWidget(),
        Expanded(child: MainContentWidget()),
        ActionOverlayWidget(),
      ],
    );
  }
}
