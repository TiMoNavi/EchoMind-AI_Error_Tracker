import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/core/api_client.dart';

class QuestionDetail {
  final String id;
  final String? imageUrl;
  final String? content;
  final String? options;
  final bool? isCorrect;
  final String? source;
  final String? questionNumber;
  final String? score;
  final String? attitude;
  final String? modelId;
  final String? modelName;
  final String? knowledgePointId;
  final String? knowledgePointName;

  const QuestionDetail({
    required this.id,
    this.imageUrl,
    this.content,
    this.options,
    this.isCorrect,
    this.source,
    this.questionNumber,
    this.score,
    this.attitude,
    this.modelId,
    this.modelName,
    this.knowledgePointId,
    this.knowledgePointName,
  });

  factory QuestionDetail.fromJson(Map<String, dynamic> json) => QuestionDetail(
    id: json['id'] ?? '',
    imageUrl: json['image_url'],
    content: json['content'],
    options: json['options'],
    isCorrect: json['is_correct'],
    source: json['source'],
    questionNumber: json['question_number'],
    score: json['score'],
    attitude: json['attitude'],
    modelId: json['model_id'],
    modelName: json['model_name'],
    knowledgePointId: json['knowledge_point_id'],
    knowledgePointName: json['knowledge_point_name'],
  );
}

final questionDetailProvider =
    FutureProvider.family<QuestionDetail, String>((ref, questionId) async {
  final res = await ApiClient().dio.get('/questions/$questionId');
  return QuestionDetail.fromJson(res.data);
});
