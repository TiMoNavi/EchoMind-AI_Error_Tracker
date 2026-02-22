import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/core/api_client.dart';

class PredictionScore {
  final double predictedScore;
  final double targetScore;
  final List<ScorePathItem> scorePath;
  final List<TrendPoint> trend;
  final List<PriorityModel> priorityModels;

  const PredictionScore({
    required this.predictedScore,
    required this.targetScore,
    required this.scorePath,
    required this.trend,
    required this.priorityModels,
  });

  factory PredictionScore.fromJson(Map<String, dynamic> json) => PredictionScore(
    predictedScore: (json['predicted_score'] as num?)?.toDouble() ?? 0,
    targetScore: (json['target_score'] as num?)?.toDouble() ?? 85,
    scorePath: (json['score_path'] as List?)
        ?.map((e) => ScorePathItem.fromJson(e))
        .toList() ?? [],
    trend: (json['trend'] as List?)
        ?.map((e) => TrendPoint.fromJson(e))
        .toList() ?? [],
    priorityModels: (json['priority_models'] as List?)
        ?.map((e) => PriorityModel.fromJson(e))
        .toList() ?? [],
  );
}

class ScorePathItem {
  final String questionLabel;
  final String score;
  final String modelName;
  final String modelId;
  final String priority;

  const ScorePathItem({
    required this.questionLabel,
    required this.score,
    required this.modelName,
    required this.modelId,
    required this.priority,
  });

  factory ScorePathItem.fromJson(Map<String, dynamic> json) => ScorePathItem(
    questionLabel: json['question_label'] ?? '',
    score: json['score'] ?? '',
    modelName: json['model_name'] ?? '',
    modelId: json['model_id'] ?? '',
    priority: json['priority'] ?? '中',
  );
}

class TrendPoint {
  final String label;
  final double value;

  const TrendPoint({required this.label, required this.value});

  factory TrendPoint.fromJson(Map<String, dynamic> json) => TrendPoint(
    label: json['label'] ?? '',
    value: (json['value'] as num?)?.toDouble() ?? 0,
  );
}

class PriorityModel {
  final String modelId;
  final String modelName;
  final int level;
  final String description;

  const PriorityModel({
    required this.modelId,
    required this.modelName,
    required this.level,
    required this.description,
  });

  factory PriorityModel.fromJson(Map<String, dynamic> json) => PriorityModel(
    modelId: json['model_id'] ?? '',
    modelName: json['model_name'] ?? '',
    level: json['level'] ?? 0,
    description: json['description'] ?? '',
  );
}

final predictionProvider = FutureProvider<PredictionScore>((ref) async {
  final res = await ApiClient().dio.get('/prediction/score');
  return PredictionScore.fromJson(res.data);
});
