import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/core/api_client.dart';

class WeeklyReviewData {
  // 基础统计
  final int totalQuestions;
  final int correctCount;
  final int errorCount;
  final int newMastered;

  // 分数变化
  final double scoreChange;
  final double lastWeekScore;
  final double thisWeekScore;

  // 四维能力
  final double formulaMemoryRate;
  final double modelIdentifyRate;
  final double executionCorrectRate;
  final double overallCorrectRate;

  // 列表数据
  final List<String> progressItems;
  final List<String> focusItems;

  // 计算属性
  double get correctRate =>
      totalQuestions > 0 ? correctCount / totalQuestions : 0;

  const WeeklyReviewData({
    this.totalQuestions = 0,
    this.correctCount = 0,
    this.errorCount = 0,
    this.newMastered = 0,
    this.scoreChange = 0,
    this.lastWeekScore = 0,
    this.thisWeekScore = 0,
    this.formulaMemoryRate = 0,
    this.modelIdentifyRate = 0,
    this.executionCorrectRate = 0,
    this.overallCorrectRate = 0,
    this.progressItems = const [],
    this.focusItems = const [],
  });

  factory WeeklyReviewData.fromJson(Map<String, dynamic> json) {
    final progress = json['weekly_progress'] as Map<String, dynamic>? ?? {};
    final stats = json['dashboard_stats'] as Map<String, dynamic>? ?? {};
    return WeeklyReviewData(
      totalQuestions: progress['total_questions'] ?? 0,
      correctCount: progress['correct_count'] ?? 0,
      errorCount: progress['error_count'] ?? 0,
      newMastered: progress['new_mastered'] ?? 0,
      scoreChange: (json['score_change'] as num?)?.toDouble() ?? 0,
      lastWeekScore: (json['last_week_score'] as num?)?.toDouble() ?? 0,
      thisWeekScore: (json['this_week_score'] as num?)?.toDouble() ?? 0,
      formulaMemoryRate: (stats['formula_memory_rate'] as num?)?.toDouble() ?? 0,
      modelIdentifyRate: (stats['model_identify_rate'] as num?)?.toDouble() ?? 0,
      executionCorrectRate: (stats['calculation_accuracy'] as num?)?.toDouble() ?? 0,
      overallCorrectRate: (stats['reading_accuracy'] as num?)?.toDouble() ?? 0,
      progressItems: (json['progress_items'] as List?)?.cast<String>() ?? [],
      focusItems: (json['focus_item_names'] as List?)?.cast<String>() ?? [],
    );
  }
}

final weeklyReviewProvider = FutureProvider<WeeklyReviewData>((ref) async {
  try {
    final res = await ApiClient().dio.get('/weekly-review');
    return WeeklyReviewData.fromJson(res.data);
  } catch (_) {
    // API 尚未实现时返回默认数据
    return const WeeklyReviewData();
  }
});
