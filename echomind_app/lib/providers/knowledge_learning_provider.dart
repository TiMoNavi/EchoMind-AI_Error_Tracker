import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/core/api_client.dart';

class LearningSession {
  final String knowledgePointId;
  final String knowledgePointName;
  final int currentStep;
  final List<Map<String, dynamic>> dialogues;

  const LearningSession({
    this.knowledgePointId = '',
    this.knowledgePointName = '',
    this.currentStep = 0,
    this.dialogues = const [],
  });

  factory LearningSession.fromJson(Map<String, dynamic> json) =>
      LearningSession(
        knowledgePointId: json['knowledge_point_id'] ?? '',
        knowledgePointName: json['knowledge_point_name'] ?? '',
        currentStep: json['current_step'] ?? 0,
        dialogues: (json['dialogues'] as List?)
                ?.map((e) => Map<String, dynamic>.from(e))
                .toList() ??
            [],
      );
}

final knowledgeLearningProvider =
    FutureProvider<LearningSession?>((ref) async {
  try {
    final res = await ApiClient().dio.get('/knowledge/learning/session');
    return LearningSession.fromJson(res.data);
  } catch (_) {
    return null;
  }
});
