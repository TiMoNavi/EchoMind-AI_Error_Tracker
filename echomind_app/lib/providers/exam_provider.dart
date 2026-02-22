import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/core/api_client.dart';

class HeatmapQuestion {
  final int num;
  final int level;
  const HeatmapQuestion({required this.num, required this.level});

  factory HeatmapQuestion.fromJson(Map<String, dynamic> json) => HeatmapQuestion(
    num: json['num'] ?? 0,
    level: json['level'] ?? 0,
  );
}

class QuestionTypeItem {
  final String title;
  final String subtitle;
  final String count;
  final int level;
  const QuestionTypeItem({required this.title, required this.subtitle, required this.count, required this.level});

  factory QuestionTypeItem.fromJson(Map<String, dynamic> json) => QuestionTypeItem(
    title: json['title'] ?? '',
    subtitle: json['subtitle'] ?? '',
    count: json['count'] ?? '',
    level: json['level'] ?? 0,
  );
}

class RecentExam {
  final String id;
  final String title;
  final String date;
  final String count;
  const RecentExam({required this.id, required this.title, required this.date, required this.count});

  factory RecentExam.fromJson(Map<String, dynamic> json) => RecentExam(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    date: json['date'] ?? '',
    count: json['count'] ?? '',
  );
}

final examHeatmapProvider = FutureProvider<List<HeatmapQuestion>>((ref) async {
  final res = await ApiClient().dio.get('/exams/heatmap');
  return (res.data as List).map((e) => HeatmapQuestion.fromJson(e)).toList();
});

final questionTypesProvider = FutureProvider<List<QuestionTypeItem>>((ref) async {
  final res = await ApiClient().dio.get('/exams/question-types');
  return (res.data as List).map((e) => QuestionTypeItem.fromJson(e)).toList();
});

final recentExamsProvider = FutureProvider<List<RecentExam>>((ref) async {
  final res = await ApiClient().dio.get('/exams/recent');
  return (res.data as List).map((e) => RecentExam.fromJson(e)).toList();
});
