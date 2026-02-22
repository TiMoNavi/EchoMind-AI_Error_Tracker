import 'package:json_annotation/json_annotation.dart';

part 'knowledge_point.g.dart';

@JsonSerializable()
class KnowledgePointItem {
  final String id;
  final String name;
  @JsonKey(name: 'conclusion_level')
  final int conclusionLevel;
  final String? description;

  const KnowledgePointItem({
    required this.id,
    required this.name,
    required this.conclusionLevel,
    this.description,
  });

  factory KnowledgePointItem.fromJson(Map<String, dynamic> json) =>
      _$KnowledgePointItemFromJson(json);
}

@JsonSerializable()
class SectionNode {
  final String section;
  final List<KnowledgePointItem> items;

  const SectionNode({required this.section, required this.items});

  factory SectionNode.fromJson(Map<String, dynamic> json) =>
      _$SectionNodeFromJson(json);
}

@JsonSerializable()
class ChapterNode {
  final String chapter;
  final List<SectionNode> sections;

  const ChapterNode({required this.chapter, required this.sections});

  factory ChapterNode.fromJson(Map<String, dynamic> json) =>
      _$ChapterNodeFromJson(json);
}
