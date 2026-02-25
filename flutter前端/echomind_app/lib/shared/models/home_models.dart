/// Data models for the Home page.

class HomeDashboard {
  final int predictedScore;
  final int totalScore;
  final int targetScore;
  final List<int> trendData;
  final int scoreChange;
  final int todayClosures;
  final String studyTime;
  final int weeklyClosures;
  final int undiagnosedCount;

  const HomeDashboard({
    required this.predictedScore,
    this.totalScore = 100,
    required this.targetScore,
    required this.trendData,
    required this.scoreChange,
    required this.todayClosures,
    required this.studyTime,
    required this.weeklyClosures,
    required this.undiagnosedCount,
  });

  factory HomeDashboard.fromJson(Map<String, dynamic> json) {
    return HomeDashboard(
      predictedScore: json['predicted_score'] as int,
      totalScore: json['total_score'] as int? ?? 100,
      targetScore: json['target_score'] as int,
      trendData: (json['trend_data'] as List).cast<int>(),
      scoreChange: json['score_change'] as int,
      todayClosures: json['today_closures'] as int,
      studyTime: json['study_time'] as String,
      weeklyClosures: json['weekly_closures'] as int,
      undiagnosedCount: json['undiagnosed_count'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'predicted_score': predictedScore,
    'total_score': totalScore,
    'target_score': targetScore,
    'trend_data': trendData,
    'score_change': scoreChange,
    'today_closures': todayClosures,
    'study_time': studyTime,
    'weekly_closures': weeklyClosures,
    'undiagnosed_count': undiagnosedCount,
  };
}

class Recommendation {
  final String id;
  final String type; // 'diagnosis', 'model_training', 'knowledge', 'review'
  final String title;
  final List<String> tags;
  final String route;
  final bool isUrgent;

  const Recommendation({
    required this.id,
    required this.type,
    required this.title,
    required this.tags,
    required this.route,
    this.isUrgent = false,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      tags: (json['tags'] as List).cast<String>(),
      route: json['route'] as String,
      isUrgent: json['is_urgent'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'title': title,
    'tags': tags,
    'route': route,
    'is_urgent': isUrgent,
  };
}

class RecentUpload {
  final int pendingCount;
  final String summary;

  const RecentUpload({
    required this.pendingCount,
    required this.summary,
  });

  factory RecentUpload.fromJson(Map<String, dynamic> json) {
    return RecentUpload(
      pendingCount: json['pending_count'] as int,
      summary: json['summary'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'pending_count': pendingCount,
    'summary': summary,
  };
}
