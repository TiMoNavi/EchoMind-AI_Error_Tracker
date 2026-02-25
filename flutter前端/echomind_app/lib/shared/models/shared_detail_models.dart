/// Data models shared by Model Detail and Knowledge Detail pages.

class TrainingRecord {
  final String id;
  final String date;
  final String result;
  final String duration;

  const TrainingRecord({
    required this.id,
    required this.date,
    required this.result,
    required this.duration,
  });

  factory TrainingRecord.fromJson(Map<String, dynamic> json) {
    return TrainingRecord(
      id: json['id'] as String,
      date: json['date'] as String,
      result: json['result'] as String,
      duration: json['duration'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date,
    'result': result,
    'duration': duration,
  };
}

class PrerequisiteKnowledge {
  final String id;
  final String name;
  final String level;
  final String status; // 'mastered', 'learning', 'weak'

  const PrerequisiteKnowledge({
    required this.id,
    required this.name,
    required this.level,
    required this.status,
  });

  factory PrerequisiteKnowledge.fromJson(Map<String, dynamic> json) {
    return PrerequisiteKnowledge(
      id: json['id'] as String,
      name: json['name'] as String,
      level: json['level'] as String,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'level': level,
    'status': status,
  };
}

class RelatedQuestion {
  final String id;
  final String title;
  final String source;
  final bool isCorrect;

  const RelatedQuestion({
    required this.id,
    required this.title,
    required this.source,
    required this.isCorrect,
  });

  factory RelatedQuestion.fromJson(Map<String, dynamic> json) {
    return RelatedQuestion(
      id: json['id'] as String,
      title: json['title'] as String,
      source: json['source'] as String,
      isCorrect: json['is_correct'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'source': source,
    'is_correct': isCorrect,
  };
}
