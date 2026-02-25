/// Data models for Question Detail page.

class QuestionDetail {
  final String id;
  final String title;
  final String content;
  final List<String> images;
  final String userAnswer;
  final String correctAnswer;
  final bool isCorrect;
  final String? diagnosisStatus; // 'correct', 'wrong', 'pending'
  final String sourceExam;
  final String difficulty;

  const QuestionDetail({
    required this.id,
    required this.title,
    required this.content,
    this.images = const [],
    required this.userAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    this.diagnosisStatus,
    required this.sourceExam,
    required this.difficulty,
  });

  factory QuestionDetail.fromJson(Map<String, dynamic> json) {
    return QuestionDetail(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      images: (json['images'] as List?)?.cast<String>() ?? [],
      userAnswer: json['user_answer'] as String,
      correctAnswer: json['correct_answer'] as String,
      isCorrect: json['is_correct'] as bool,
      diagnosisStatus: json['diagnosis_status'] as String?,
      sourceExam: json['source_exam'] as String,
      difficulty: json['difficulty'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'images': images,
    'user_answer': userAnswer,
    'correct_answer': correctAnswer,
    'is_correct': isCorrect,
    'diagnosis_status': diagnosisStatus,
    'source_exam': sourceExam,
    'difficulty': difficulty,
  };
}

class QuestionRelation {
  final String id;
  final String name;
  final String type; // 'model' or 'knowledge'
  final String level;

  const QuestionRelation({
    required this.id,
    required this.name,
    required this.type,
    required this.level,
  });

  factory QuestionRelation.fromJson(Map<String, dynamic> json) {
    return QuestionRelation(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      level: json['level'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'level': level,
  };
}
