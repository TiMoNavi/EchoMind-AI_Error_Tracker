// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Student _$StudentFromJson(Map<String, dynamic> json) => Student(
      id: json['id'] as String,
      phone: json['phone'] as String,
      nickname: json['nickname'] as String?,
      regionId: json['region_id'] as String,
      subject: json['subject'] as String,
      targetScore: (json['target_score'] as num).toInt(),
      predictedScore: (json['predicted_score'] as num?)?.toDouble(),
      avatarUrl: json['avatar_url'] as String?,
    );

Map<String, dynamic> _$StudentToJson(Student instance) => <String, dynamic>{
      'id': instance.id,
      'phone': instance.phone,
      'nickname': instance.nickname,
      'region_id': instance.regionId,
      'subject': instance.subject,
      'target_score': instance.targetScore,
      'predicted_score': instance.predictedScore,
      'avatar_url': instance.avatarUrl,
    };
