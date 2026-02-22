import 'package:json_annotation/json_annotation.dart';

part 'question.g.dart';

@JsonSerializable()
class Question {
  final String id;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @JsonKey(name: 'is_correct')
  final bool? isCorrect;
  final String source;
  @JsonKey(name: 'diagnosis_status')
  final String diagnosisStatus;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  const Question({
    required this.id,
    this.imageUrl,
    this.isCorrect,
    required this.source,
    required this.diagnosisStatus,
    this.createdAt,
  });

  factory Question.fromJson(Map<String, dynamic> json) =>
      _$QuestionFromJson(json);
}

@JsonSerializable()
class HistoryDateGroup {
  final String date;
  final List<Question> questions;

  const HistoryDateGroup({required this.date, required this.questions});

  factory HistoryDateGroup.fromJson(Map<String, dynamic> json) =>
      _$HistoryDateGroupFromJson(json);
}
