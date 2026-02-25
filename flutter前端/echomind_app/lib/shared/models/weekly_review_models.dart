/// Data models for the Weekly Review page.

class WeeklyReview {
  final String period;
  final int closures;
  final String studyTime;
  final int scoreChange;
  final List<DailyScore> scoreHistory;

  const WeeklyReview({
    required this.period,
    required this.closures,
    required this.studyTime,
    required this.scoreChange,
    required this.scoreHistory,
  });

  factory WeeklyReview.fromJson(Map<String, dynamic> json) {
    return WeeklyReview(
      period: json['period'] as String,
      closures: json['closures'] as int,
      studyTime: json['study_time'] as String,
      scoreChange: json['score_change'] as int,
      scoreHistory: (json['score_history'] as List)
          .map((e) => DailyScore.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'period': period,
    'closures': closures,
    'study_time': studyTime,
    'score_change': scoreChange,
    'score_history': scoreHistory.map((e) => e.toJson()).toList(),
  };
}

class DailyScore {
  final String date;
  final int score;

  const DailyScore({required this.date, required this.score});

  factory DailyScore.fromJson(Map<String, dynamic> json) {
    return DailyScore(
      date: json['date'] as String,
      score: json['score'] as int,
    );
  }

  Map<String, dynamic> toJson() => {'date': date, 'score': score};
}

class WeeklyProgress {
  final String category;
  final int completed;
  final int total;

  const WeeklyProgress({
    required this.category,
    required this.completed,
    required this.total,
  });

  factory WeeklyProgress.fromJson(Map<String, dynamic> json) {
    return WeeklyProgress(
      category: json['category'] as String,
      completed: json['completed'] as int,
      total: json['total'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'category': category,
    'completed': completed,
    'total': total,
  };
}

class NextWeekFocus {
  final String title;
  final String reason;

  const NextWeekFocus({required this.title, required this.reason});

  factory NextWeekFocus.fromJson(Map<String, dynamic> json) {
    return NextWeekFocus(
      title: json['title'] as String,
      reason: json['reason'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'title': title, 'reason': reason};
}
