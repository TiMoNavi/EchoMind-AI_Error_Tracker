/// Data models for Memory (flashcard system) page.

class MemoryDashboard {
  final int todayDueCount;
  final String retentionRate;
  final int totalReviewed;
  final int totalCards;

  const MemoryDashboard({
    required this.todayDueCount,
    required this.retentionRate,
    required this.totalReviewed,
    required this.totalCards,
  });

  factory MemoryDashboard.fromJson(Map<String, dynamic> json) {
    return MemoryDashboard(
      todayDueCount: json['today_due_count'] as int,
      retentionRate: json['retention_rate'] as String,
      totalReviewed: json['total_reviewed'] as int,
      totalCards: json['total_cards'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'today_due_count': todayDueCount,
    'retention_rate': retentionRate,
    'total_reviewed': totalReviewed,
    'total_cards': totalCards,
  };
}

class CardCategory {
  final String id;
  final String name;
  final int totalCount;
  final int dueCount;
  final String colorHex;

  const CardCategory({
    required this.id,
    required this.name,
    required this.totalCount,
    required this.dueCount,
    required this.colorHex,
  });

  factory CardCategory.fromJson(Map<String, dynamic> json) {
    return CardCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      totalCount: json['total_count'] as int,
      dueCount: json['due_count'] as int,
      colorHex: json['color_hex'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'total_count': totalCount,
    'due_count': dueCount,
    'color_hex': colorHex,
  };
}
