import 'package:json_annotation/json_annotation.dart';

part 'knowledge_point.g.dart';

@JsonSerializable()
class KnowledgePoint {
  final int id;
  final String name;
  final int? level;
  @JsonKey(name: 'parent_id')
  final int? parentId;
  final List<KnowledgePoint>? children;

  const KnowledgePoint({
    required this.id,
    required this.name,
    this.level,
    this.parentId,
    this.children,
  });

  factory KnowledgePoint.fromJson(Map<String, dynamic> json) =>
      _$KnowledgePointFromJson(json);
  Map<String, dynamic> toJson() => _$KnowledgePointToJson(this);
}
