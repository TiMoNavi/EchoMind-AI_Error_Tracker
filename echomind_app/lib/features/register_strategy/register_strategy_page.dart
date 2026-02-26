import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/providers/strategy_provider.dart';
import 'package:echomind_app/features/register_strategy/widgets/top_frame_widget.dart';
import 'package:echomind_app/features/register_strategy/widgets/strategy_header_widget.dart';
import 'package:echomind_app/features/register_strategy/widgets/strategy_table_widget.dart';
import 'package:echomind_app/features/register_strategy/widgets/score_compare_widget.dart';

class RegisterStrategyPage extends ConsumerStatefulWidget {
  const RegisterStrategyPage({super.key});

  @override
  ConsumerState<RegisterStrategyPage> createState() =>
      _RegisterStrategyPageState();
}

class _RegisterStrategyPageState extends ConsumerState<RegisterStrategyPage> {
  @override
  void initState() {
    super.initState();
    // 页面加载时拉取策略 + 可用分数档
    Future.microtask(() {
      ref.read(strategyProvider.notifier).fetchStrategy();
      ref.read(strategyProvider.notifier).fetchTemplates();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(strategyProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            const TopFrameWidget(),
            Expanded(child: _buildBody(state)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(StrategyState state) {
    if (state.isLoading && state.strategy == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null && state.strategy == null) {
      return _buildError(state.errorMessage!);
    }

    if (!state.hasStrategy) {
      return _buildEmpty();
    }

    return _buildStrategyContent(state);
  }

  /// 策略内容主体
  Widget _buildStrategyContent(StrategyState state) {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: const [
            StrategyHeaderWidget(),
            SizedBox(height: 16),
            StrategyTableWidget(),
            SizedBox(height: 16),
            ScoreCompareWidget(),
          ],
        ),
        if (state.isLoading)
          const Positioned.fill(
            child: ColoredBox(
              color: Color(0x33FFFFFF),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }

  /// 尚未生成策略
  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assignment_outlined,
                size: 64, color: AppTheme.textSecondary),
            const SizedBox(height: 16),
            const Text('尚未生成卷面策略',
                style: TextStyle(fontSize: 16, color: AppTheme.textSecondary)),
            const SizedBox(height: 8),
            const Text('输入目标分数，系统将为你生成个性化的卷面策略',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _showGenerateDialog,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('生成策略'),
            ),
          ],
        ),
      ),
    );
  }

  /// 错误状态
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
              onPressed: () =>
                  ref.read(strategyProvider.notifier).fetchStrategy(),
              child: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }

  void _showGenerateDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('设定目标分数'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: '输入目标分（30-150）',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              final score = int.tryParse(controller.text);
              if (score == null || score < 30 || score > 150) return;
              Navigator.pop(ctx);
              ref
                  .read(strategyProvider.notifier)
                  .generateStrategy(targetScore: score);
            },
            child: const Text('生成'),
          ),
        ],
      ),
    );
  }
}
