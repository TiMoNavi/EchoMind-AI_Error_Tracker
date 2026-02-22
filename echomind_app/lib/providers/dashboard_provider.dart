import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/core/api_client.dart';

class DashboardData {
  final int totalQuestions;
  final int errorCount;
  final int masteryCount;
  final int weakCount;
  final double? predictedScore;
  final double formulaMemoryRate;
  final double modelIdentifyRate;
  final double calculationAccuracy;
  final double readingAccuracy;

  const DashboardData({
    this.totalQuestions = 0,
    this.errorCount = 0,
    this.masteryCount = 0,
    this.weakCount = 0,
    this.predictedScore,
    this.formulaMemoryRate = 0,
    this.modelIdentifyRate = 0,
    this.calculationAccuracy = 0,
    this.readingAccuracy = 0,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) => DashboardData(
        totalQuestions: json['total_questions'] ?? 0,
        errorCount: json['error_count'] ?? 0,
        masteryCount: json['mastery_count'] ?? 0,
        weakCount: json['weak_count'] ?? 0,
        predictedScore: (json['predicted_score'] as num?)?.toDouble(),
        formulaMemoryRate: (json['formula_memory_rate'] as num?)?.toDouble() ?? 0,
        modelIdentifyRate: (json['model_identify_rate'] as num?)?.toDouble() ?? 0,
        calculationAccuracy: (json['calculation_accuracy'] as num?)?.toDouble() ?? 0,
        readingAccuracy: (json['reading_accuracy'] as num?)?.toDouble() ?? 0,
      );
}

final dashboardProvider = FutureProvider<DashboardData>((ref) async {
  final res = await ApiClient().dio.get('/dashboard');
  return DashboardData.fromJson(res.data);
});
