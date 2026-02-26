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
    targetScore: (json['target_score'] as num?)?.toDouble() ?? 90,
    scorePath: (json['score_path'] as List?)
        ?.map((e) => ScorePathItem.fromJson(e))
        .toList() ?? [],
    trend: (json['trend_data'] as List?)
        ?.map((e) => TrendPoint.fromJson(e))
        .toList() ?? [],
    priorityModels: (json['priority_models'] as List?)
        ?.map((e) => PriorityModel.fromJson(e))
        .toList() ?? [],
  );
}

class ScorePathItem {
  final String label;
  final double current;
  final double target;

  const ScorePathItem({
    required this.label,
    required this.current,
    required this.target,
  });

  double get gap => target - current;

  factory ScorePathItem.fromJson(Map<String, dynamic> json) => ScorePathItem(
    label: json['label'] ?? '',
    current: (json['current'] as num?)?.toDouble() ?? 0,
    target: (json['target'] as num?)?.toDouble() ?? 0,
  );
}

class TrendPoint {
  final String label;
  final double value;

  const TrendPoint({required this.label, required this.value});

  factory TrendPoint.fromJson(Map<String, dynamic> json) {
    // 后端返回 date (YYYY-MM-DD) + score，适配为 label + value
    final date = json['date'] as String? ?? '';
    String label;
    if (date.length >= 10) {
      final month = int.tryParse(date.substring(5, 7)) ?? 0;
      final day = int.tryParse(date.substring(8, 10)) ?? 0;
      label = '$month/$day';
    } else {
      label = date;
    }
    return TrendPoint(
      label: label,
      value: (json['score'] as num?)?.toDouble() ?? 0,
    );
  }
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
    level: json['current_level'] ?? 0,
    description: '错题 ${json['error_count'] ?? 0} 道',
  );
}

final predictionProvider = FutureProvider<PredictionScore>((ref) async {
  final res = await ApiClient().dio.get('/prediction/score');
  return PredictionScore.fromJson(res.data);
});
