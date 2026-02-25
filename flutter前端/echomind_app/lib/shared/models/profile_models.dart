/// Data models for the Profile page.

class UserProfile {
  final String name;
  final String initial;
  final String subtitle;
  final List<String> tags;
  final int targetScore;
  final int currentScore;

  const UserProfile({
    required this.name,
    required this.initial,
    required this.subtitle,
    required this.tags,
    required this.targetScore,
    required this.currentScore,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String,
      initial: json['initial'] as String,
      subtitle: json['subtitle'] as String,
      tags: (json['tags'] as List).cast<String>(),
      targetScore: json['target_score'] as int,
      currentScore: json['current_score'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'initial': initial,
    'subtitle': subtitle,
    'tags': tags,
    'target_score': targetScore,
    'current_score': currentScore,
  };
}

class LearningStats {
  final int cumulativeDays;
  final int totalClosures;
  final String totalStudyTime;
  final int predictedImprovement;

  const LearningStats({
    required this.cumulativeDays,
    required this.totalClosures,
    required this.totalStudyTime,
    required this.predictedImprovement,
  });

  factory LearningStats.fromJson(Map<String, dynamic> json) {
    return LearningStats(
      cumulativeDays: json['cumulative_days'] as int,
      totalClosures: json['total_closures'] as int,
      totalStudyTime: json['total_study_time'] as String,
      predictedImprovement: json['predicted_improvement'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'cumulative_days': cumulativeDays,
    'total_closures': totalClosures,
    'total_study_time': totalStudyTime,
    'predicted_improvement': predictedImprovement,
  };
}
