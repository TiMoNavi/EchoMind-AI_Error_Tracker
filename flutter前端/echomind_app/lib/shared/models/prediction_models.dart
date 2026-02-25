/// Data models for the Prediction Center page.

class PredictionScore {
  final int score;
  final int totalScore;
  final int targetScore;
  final String gapDescription;
  final List<double> trendData;
  final String trendChange;

  const PredictionScore({
    required this.score,
    this.totalScore = 100,
    required this.targetScore,
    required this.gapDescription,
    required this.trendData,
    required this.trendChange,
  });

  factory PredictionScore.fromJson(Map<String, dynamic> json) {
    return PredictionScore(
      score: json['score'] as int,
      totalScore: json['total_score'] as int? ?? 100,
      targetScore: json['target_score'] as int,
      gapDescription: json['gap_description'] as String,
      trendData: (json['trend_data'] as List).map((e) => (e as num).toDouble()).toList(),
      trendChange: json['trend_change'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'score': score,
    'total_score': totalScore,
    'target_score': targetScore,
    'gap_description': gapDescription,
    'trend_data': trendData,
    'trend_change': trendChange,
  };
}

class PriorityModelItem {
  final String id;
  final String name;
  final String description;
  final String level;
  final int predictedGain;

  const PriorityModelItem({
    required this.id,
    required this.name,
    required this.description,
    required this.level,
    required this.predictedGain,
  });

  factory PriorityModelItem.fromJson(Map<String, dynamic> json) {
    return PriorityModelItem(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      level: json['level'] as String,
      predictedGain: json['predicted_gain'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'level': level,
    'predicted_gain': predictedGain,
  };
}

class ScorePathEntry {
  final String modelName;
  final String currentLevel;
  final String targetLevel;
  final int gainPoints;

  const ScorePathEntry({
    required this.modelName,
    required this.currentLevel,
    required this.targetLevel,
    required this.gainPoints,
  });

  factory ScorePathEntry.fromJson(Map<String, dynamic> json) {
    return ScorePathEntry(
      modelName: json['model_name'] as String,
      currentLevel: json['current_level'] as String,
      targetLevel: json['target_level'] as String,
      gainPoints: json['gain_points'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'model_name': modelName,
    'current_level': currentLevel,
    'target_level': targetLevel,
    'gain_points': gainPoints,
  };
}
