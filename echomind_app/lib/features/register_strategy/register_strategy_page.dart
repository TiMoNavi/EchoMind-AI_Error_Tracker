import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/features/register_strategy/widgets/score_compare_widget.dart';
import 'package:echomind_app/features/register_strategy/widgets/strategy_header_widget.dart';
import 'package:echomind_app/features/register_strategy/widgets/strategy_table_widget.dart';
import 'package:echomind_app/features/register_strategy/widgets/top_frame_widget.dart';
import 'package:echomind_app/providers/strategy_provider.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_background_blobs.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';

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
    Future.microtask(() {
      ref.read(strategyProvider.notifier).fetchStrategy();
      ref.read(strategyProvider.notifier).fetchTemplates();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(strategyProvider);

    return Scaffold(
      backgroundColor: AppTheme.canvas,
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

    return Stack(
      children: [
        const ClayBackgroundBlobs(),
        ListView(
          clipBehavior: Clip.none,
          padding: const EdgeInsets.only(bottom: 24),
          children: const [
            StrategyHeaderWidget(),
            SizedBox(height: 20),
            StrategyTableWidget(),
            SizedBox(height: 20),
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

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ClayCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.assignment_outlined,
                  size: 56, color: AppTheme.muted),
              const SizedBox(height: 12),
              Text('尚未生成卷面策略',
                  style: AppTheme.heading(size: 20, weight: FontWeight.w900)),
              const SizedBox(height: 6),
              Text(
                '输入目标分数后，系统会生成对应的题型取舍和作答优先级。',
                textAlign: TextAlign.center,
                style: AppTheme.body(
                    size: 14, weight: FontWeight.w600, color: AppTheme.muted),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                height: 44,
                decoration: BoxDecoration(
                  gradient: AppTheme.gradientPrimary,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  boxShadow: AppTheme.shadowClayButton,
                ),
                child: ElevatedButton.icon(
                  onPressed: _showGenerateDialog,
                  icon: const Icon(Icons.auto_awesome),
                  label: Text('生成策略',
                      style: AppTheme.body(
                          size: 14,
                          weight: FontWeight.w800,
                          color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ClayCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppTheme.danger),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTheme.body(
                    size: 14, weight: FontWeight.w600, color: AppTheme.muted),
              ),
              const SizedBox(height: 14),
              OutlinedButton(
                onPressed: () =>
                    ref.read(strategyProvider.notifier).fetchStrategy(),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.accent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                ),
                child: Text('重新获取',
                    style: AppTheme.body(size: 14, weight: FontWeight.w800)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showGenerateDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
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
                onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
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
        );
      },
    );
  }
}
