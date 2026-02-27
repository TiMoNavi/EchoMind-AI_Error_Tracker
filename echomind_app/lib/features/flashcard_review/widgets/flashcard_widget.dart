import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';
import 'package:echomind_app/providers/flashcard_provider.dart';

class FlashcardWidget extends ConsumerStatefulWidget {
  const FlashcardWidget({super.key});

  @override
  ConsumerState<FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends ConsumerState<FlashcardWidget> {
  bool _flipped = false;
  int _index = 0;
  double _dragOffset = 0;

  static const _mockCards = [
    Flashcard(
      id: 'mock-1',
      question: '库仑定律的适用条件是什么？',
      answer: '库仑定律适用于真空中两个静止点电荷之间的相互作用力。',
    ),
  ];

  void _goTo(int index, int total) {
    if (index < 0 || index >= total) return;
    setState(() {
      _flipped = false;
      _index = index;
    });
  }

  void _onFeedback(int total) {
    if (_index < total - 1) {
      _goTo(_index + 1, total);
    } else {
      setState(() => _flipped = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardsAsync = ref.watch(flashcardProvider);
    final cards = cardsAsync.whenOrNull(data: (d) => d.isNotEmpty ? d : null) ??
        _mockCards;

    final currentIndex = _index.clamp(0, cards.length - 1).toInt();
    final card = cards[currentIndex];
    final tag = _deriveTag(card.question);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: GestureDetector(
            onTap: () => setState(() => _flipped = !_flipped),
            onHorizontalDragUpdate: (d) =>
                setState(() => _dragOffset += d.delta.dx),
            onHorizontalDragEnd: (_) {
              if (_dragOffset > 60) _goTo(currentIndex - 1, cards.length);
              if (_dragOffset < -60) _goTo(currentIndex + 1, cards.length);
              setState(() => _dragOffset = 0);
            },
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    transform:
                        Matrix4.translationValues(_dragOffset * 0.3, 0, 0),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                      boxShadow: AppTheme.shadowClayCard,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 44,
                        vertical: 16,
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: ScaleTransition(
                            scale: Tween(begin: 0.95, end: 1.0).animate(anim),
                            child: child,
                          ),
                        ),
                        child:
                            _flipped ? _backContent(card) : _frontContent(card),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    top: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.canvas,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      child: Text(
                        tag,
                        style: AppTheme.label(size: 12, color: AppTheme.accent)
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 12,
                    top: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.canvas,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      child: Text(
                        _flipped ? '点击翻回' : '点击翻转',
                        style: AppTheme.label(size: 11),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: currentIndex > 0
                          ? () => _goTo(currentIndex - 1, cards.length)
                          : null,
                      child: Container(
                        width: 32,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.chevron_left,
                          size: 26,
                          color: currentIndex > 0
                              ? AppTheme.textSecondary
                              : AppTheme.divider,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: currentIndex < cards.length - 1
                          ? () => _goTo(currentIndex + 1, cards.length)
                          : null,
                      child: Container(
                        width: 32,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.chevron_right,
                          size: 26,
                          color: currentIndex < cards.length - 1
                              ? AppTheme.textSecondary
                              : AppTheme.divider,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 6),
          child: Text(
            _flipped ? '已翻转 · 查看下方解析' : '点击卡片查看答案',
            style: AppTheme.label(size: 12).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _btn('忘了', AppTheme.danger, cards.length),
              const SizedBox(width: 10),
              _btn('记得', AppTheme.accent, cards.length),
              const SizedBox(width: 10),
              _btn('简单', AppTheme.success, cards.length),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: _flipped ? _analysisSection(card) : const SizedBox.shrink(),
        ),
      ],
    );
  }

  String _deriveTag(String question) {
    final lower = question.toLowerCase();
    if (lower.contains('条件') || lower.contains('condition')) return '条件卡';
    if (lower.contains('区别') || lower.contains('difference')) return '辨析卡';
    if (lower.contains('公式') || lower.contains('formula')) return '公式卡';
    return '概念卡';
  }

  Widget _frontContent(Flashcard card) {
    return Column(
      key: const ValueKey('front'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          card.question,
          style: AppTheme.heading(size: 22, weight: FontWeight.w900),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _backContent(Flashcard card) {
    return Column(
      key: const ValueKey('back'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '答案',
          style: AppTheme.label(size: 13, color: AppTheme.accent).copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          card.answer,
          style: AppTheme.body(size: 16, weight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _analysisSection(Flashcard card) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      children: [
        ClayCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('解析',
                  style: AppTheme.heading(size: 17, weight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text(
                card.answer,
                style: AppTheme.body(size: 14, weight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _btn(String label, Color color, int total) {
    return Expanded(
      child: SizedBox(
        height: 40,
        child: ElevatedButton(
          onPressed: _flipped ? () => _onFeedback(total) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            disabledBackgroundColor: color.withValues(alpha: 0.3),
            disabledForegroundColor: Colors.white54,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
            elevation: 0,
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
