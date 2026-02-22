// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Question _$QuestionFromJson(Map<String, dynamic> json) => Question(
      id: json['id'] as String,
      imageUrl: json['image_url'] as String?,
      isCorrect: json['is_correct'] as bool?,
      source: json['source'] as String,
      diagnosisStatus: json['diagnosis_status'] as String,
      createdAt: json['created_at'] as String?,
    );

HistoryDateGroup _$HistoryDateGroupFromJson(Map<String, dynamic> json) =>
    HistoryDateGroup(
      date: json['date'] as String,
      questions: (json['questions'] as List<dynamic>)
          .map((e) => Question.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
