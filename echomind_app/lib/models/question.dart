import 'package:json_annotation/json_annotation.dart';

part 'question.g.dart';

@JsonSerializable()
class Question {
  final int id;
  final String? source;
  @JsonKey(name: 'question_text')
  final String? questionText;
  @JsonKey(name: 'student_answer')
  final String? studentAnswer;
  @JsonKey(name: 'correct_answer')
  final String? correctAnswer;
  final String? status;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  const Question({
    required this.id,
    this.source,
    this.questionText,
    this.studentAnswer,
    this.correctAnswer,
    this.status,
    this.createdAt,
  });

  factory Question.fromJson(Map<String, dynamic> json) =>
      _$QuestionFromJson(json);
  Map<String, dynamic> toJson() => _$QuestionToJson(this);
}
