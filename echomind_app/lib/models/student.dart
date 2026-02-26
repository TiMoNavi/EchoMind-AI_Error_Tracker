import 'package:json_annotation/json_annotation.dart';

part 'student.g.dart';

@JsonSerializable()
class Student {
  final String id;
  final String phone;
  final String? nickname;
  @JsonKey(name: 'region_id')
  final String regionId;
  final String subject;
  @JsonKey(name: 'target_score')
  final int targetScore;
  @JsonKey(name: 'predicted_score')
  final double? predictedScore;
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;

  const Student({
    required this.id,
    required this.phone,
    this.nickname,
    required this.regionId,
    required this.subject,
    required this.targetScore,
    this.predictedScore,
    this.avatarUrl,
  });

  factory Student.fromJson(Map<String, dynamic> json) => _$StudentFromJson(json);
  Map<String, dynamic> toJson() => _$StudentToJson(this);
}
