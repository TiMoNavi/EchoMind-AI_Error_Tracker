import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/core/api_client.dart';

class RecommendationItem {
  final String icon;
  final String title;
  final List<String> tags;
  final String route;

  const RecommendationItem({
    required this.icon,
    required this.title,
    required this.tags,
    required this.route,
  });

  factory RecommendationItem.fromJson(Map<String, dynamic> json) =>
      RecommendationItem(
        icon: json['icon'] ?? '?',
        title: json['title'] ?? '',
        tags: (json['tags'] as List?)?.cast<String>() ?? [],
        route: json['route'] ?? '',
      );
}

final recommendationsProvider =
    FutureProvider<List<RecommendationItem>>((ref) async {
  final res = await ApiClient().dio.get('/recommendations');
  return (res.data as List)
      .map((e) => RecommendationItem.fromJson(e))
      .toList();
});
