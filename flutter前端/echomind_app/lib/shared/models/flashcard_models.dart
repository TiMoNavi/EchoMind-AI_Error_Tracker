/// Data models for Flashcard Review page.

class Flashcard {
  final String id;
  final String question;
  final String answer;
  final String? detail;
  final String tag;
  final String difficulty;
  final int reviewCount;

  const Flashcard({
    required this.id,
    required this.question,
    required this.answer,
    this.detail,
    required this.tag,
    required this.difficulty,
    this.reviewCount = 0,
  });

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
      detail: json['detail'] as String?,
      tag: json['tag'] as String,
      difficulty: json['difficulty'] as String,
      reviewCount: json['review_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'question': question,
    'answer': answer,
    'detail': detail,
    'tag': tag,
    'difficulty': difficulty,
    'review_count': reviewCount,
  };
}

class FlashcardSession {
  final List<Flashcard> cards;
  final int currentIndex;
  final int remembered;
  final int forgotten;

  const FlashcardSession({
    required this.cards,
    this.currentIndex = 0,
    this.remembered = 0,
    this.forgotten = 0,
  });

  factory FlashcardSession.fromJson(Map<String, dynamic> json) {
    return FlashcardSession(
      cards: (json['cards'] as List)
          .map((e) => Flashcard.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentIndex: json['current_index'] as int? ?? 0,
      remembered: json['remembered'] as int? ?? 0,
      forgotten: json['forgotten'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'cards': cards.map((e) => e.toJson()).toList(),
    'current_index': currentIndex,
    'remembered': remembered,
    'forgotten': forgotten,
  };
}
