/// Data models for Question pages (aggregate + detail).

class QuestionAggregate {
  final String questionTitle;
  final int totalAttempts;
  final String accuracy;
  final String predictedScore;
  final List<ExamAnalysis> examAnalysis;
  final List<QuestionHistory> history;

  const QuestionAggregate({
    required this.questionTitle,
    required this.totalAttempts,
    required this.accuracy,
    required this.predictedScore,
    required this.examAnalysis,
    required this.history,
  });

  factory QuestionAggregate.fromJson(Map<String, dynamic> json) {
    return QuestionAggregate(
      questionTitle: json['question_title'] as String,
      totalAttempts: json['total_attempts'] as int,
      accuracy: json['accuracy'] as String,
      predictedScore: json['predicted_score'] as String,
      examAnalysis: (json['exam_analysis'] as List)
          .map((e) => ExamAnalysis.fromJson(e as Map<String, dynamic>))
          .toList(),
      history: (json['history'] as List)
          .map((e) => QuestionHistory.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'question_title': questionTitle,
    'total_attempts': totalAttempts,
    'accuracy': accuracy,
    'predicted_score': predictedScore,
    'exam_analysis': examAnalysis.map((e) => e.toJson()).toList(),
    'history': history.map((e) => e.toJson()).toList(),
  };
}

class ExamAnalysis {
  final String examName;
  final String tag;
  final String result;

  const ExamAnalysis({
    required this.examName,
    required this.tag,
    required this.result,
  });

  factory ExamAnalysis.fromJson(Map<String, dynamic> json) {
    return ExamAnalysis(
      examName: json['exam_name'] as String,
      tag: json['tag'] as String,
      result: json['result'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'exam_name': examName,
    'tag': tag,
    'result': result,
  };
}

class QuestionHistory {
  final String date;
  final String result;
  final String timeSpent;
  final String errorType;

  const QuestionHistory({
    required this.date,
    required this.result,
    required this.timeSpent,
    required this.errorType,
  });

  factory QuestionHistory.fromJson(Map<String, dynamic> json) {
    return QuestionHistory(
      date: json['date'] as String,
      result: json['result'] as String,
      timeSpent: json['time_spent'] as String,
      errorType: json['error_type'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date,
    'result': result,
    'time_spent': timeSpent,
    'error_type': errorType,
  };
}
