import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/providers/flashcard_provider.dart';

class FlashcardWidget extends ConsumerStatefulWidget {
  const FlashcardWidget({super.key});

  @override
  ConsumerState<FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends ConsumerState<FlashcardWidget> {
  bool _flipped = false;
  int _index = 0;

  static const _mockCards = [
    Flashcard(id: 'mock', question: '库仑定律的适用条件是什么？', answer: '库仑定律适用于真空中两个静止点电荷之间的相互作用力。要求：①点电荷 ②真空 ③静止'),
  ];

  @override
  Widget build(BuildContext context) {
    final cardsAsync = ref.watch(flashcardProvider);
    final cards = cardsAsync.whenOrNull(
      data: (d) => d.isNotEmpty ? d : null,
    ) ?? _mockCards;

    final card = cards[_index % cards.length];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _flipped = !_flipped),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radiusLg)),
                alignment: Alignment.center,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _flipped ? _back(card.answer) : _front(card.question),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_flipped) _feedbackButtons(cards.length),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _front(String question) {
    return Column(
      key: const ValueKey('front'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(question, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
        const SizedBox(height: 12),
        const Text('点击卡片查看答案', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
      ],
    );
  }

  Widget _back(String answer) {
    return Column(
      key: const ValueKey('back'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('答案', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
        const SizedBox(height: 8),
        Text(answer, style: const TextStyle(fontSize: 16, height: 1.5), textAlign: TextAlign.center),
      ],
    );
  }

  void _next(int total) => setState(() {
    _flipped = false;
    _index = (_index + 1) % total;
  });

  Widget _feedbackButtons(int total) {
    return Row(children: [
      _btn('忘了', AppTheme.danger, total),
      const SizedBox(width: 12),
      _btn('记得', AppTheme.primary, total),
      const SizedBox(width: 12),
      _btn('简单', AppTheme.success, total),
    ]);
  }

  Widget _btn(String label, Color color, int total) {
    return Expanded(
      child: SizedBox(
        height: 44,
        child: ElevatedButton(
          onPressed: () => _next(total),
          style: ElevatedButton.styleFrom(
            backgroundColor: color, foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
            elevation: 0,
          ),
          child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}
