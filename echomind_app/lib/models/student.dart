import 'package:json_annotation/json_annotation.dart';

part 'student.g.dart';

@JsonSerializable()
class Student {
  final int id;
  final String username;
  final String? email;
  final String? region;
  @JsonKey(name: 'target_score')
  final int? targetScore;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  const Student({
    required this.id,
    required this.username,
    this.email,
    this.region,
    this.targetScore,
    this.createdAt,
  });

  factory Student.fromJson(Map<String, dynamic> json) => _$StudentFromJson(json);
  Map<String, dynamic> toJson() => _$StudentToJson(this);
}
