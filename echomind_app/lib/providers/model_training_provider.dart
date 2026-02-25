import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/core/api_client.dart';

class TrainingSession {
  final String modelId;
  final String modelName;
  final int currentStep;
  final List<Map<String, dynamic>> dialogues;

  const TrainingSession({
    this.modelId = '',
    this.modelName = '',
    this.currentStep = 0,
    this.dialogues = const [],
  });

  factory TrainingSession.fromJson(Map<String, dynamic> json) =>
      TrainingSession(
        modelId: json['model_id'] ?? '',
        modelName: json['model_name'] ?? '',
        currentStep: json['current_step'] ?? 0,
        dialogues: (json['dialogues'] as List?)
                ?.map((e) => Map<String, dynamic>.from(e))
                .toList() ??
            [],
      );
}

final modelTrainingProvider = FutureProvider<TrainingSession?>((ref) async {
  try {
    final res = await ApiClient().dio.get('/models/training/session');
    return TrainingSession.fromJson(res.data);
  } catch (_) {
    return null;
  }
});
