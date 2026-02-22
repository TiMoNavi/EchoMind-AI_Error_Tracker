import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/core/api_client.dart';

class DashboardData {
  final String todayClosed;
  final String studyDuration;
  final String weekClosed;
  final int predictedScore;
  final int targetScore;
  final List<int> trendData;

  const DashboardData({
    this.todayClosed = '0',
    this.studyDuration = '0m',
    this.weekClosed = '0',
    this.predictedScore = 0,
    this.targetScore = 70,
    this.trendData = const [],
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) => DashboardData(
        todayClosed: json['today_closed']?.toString() ?? '0',
        studyDuration: json['study_duration']?.toString() ?? '0m',
        weekClosed: json['week_closed']?.toString() ?? '0',
        predictedScore: json['predicted_score'] ?? 0,
        targetScore: json['target_score'] ?? 70,
        trendData: (json['trend_data'] as List?)?.cast<int>() ?? [],
      );
}

final dashboardProvider = FutureProvider<DashboardData>((ref) async {
  final res = await ApiClient().dio.get('/dashboard');
  return DashboardData.fromJson(res.data);
});
