import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/core/api_client.dart';

class RecommendationItem {
  final String targetType;
  final String targetId;
  final String targetName;
  final int currentLevel;
  final int errorCount;
  final bool isUnstable;

  const RecommendationItem({
    required this.targetType,
    required this.targetId,
    required this.targetName,
    required this.currentLevel,
    required this.errorCount,
    required this.isUnstable,
  });

  factory RecommendationItem.fromJson(Map<String, dynamic> json) =>
      RecommendationItem(
        targetType: json['target_type'] ?? '',
        targetId: json['target_id'] ?? '',
        targetName: json['target_name'] ?? '',
        currentLevel: json['current_level'] ?? 0,
        errorCount: json['error_count'] ?? 0,
        isUnstable: json['is_unstable'] ?? false,
      );
}

final recommendationsProvider =
    FutureProvider<List<RecommendationItem>>((ref) async {
  final res = await ApiClient().dio.get('/recommendations');
  return (res.data as List)
      .map((e) => RecommendationItem.fromJson(e))
      .toList();
});
