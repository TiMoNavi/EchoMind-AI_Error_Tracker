import 'package:json_annotation/json_annotation.dart';

part 'model_item.g.dart';

@JsonSerializable()
class ModelItem {
  final String id;
  final String name;
  final String? description;

  const ModelItem({required this.id, required this.name, this.description});

  factory ModelItem.fromJson(Map<String, dynamic> json) =>
      _$ModelItemFromJson(json);
}

@JsonSerializable()
class ModelSectionNode {
  final String section;
  final List<ModelItem> items;

  const ModelSectionNode({required this.section, required this.items});

  factory ModelSectionNode.fromJson(Map<String, dynamic> json) =>
      _$ModelSectionNodeFromJson(json);
}

@JsonSerializable()
class ModelChapterNode {
  final String chapter;
  final List<ModelSectionNode> sections;

  const ModelChapterNode({required this.chapter, required this.sections});

  factory ModelChapterNode.fromJson(Map<String, dynamic> json) =>
      _$ModelChapterNodeFromJson(json);
}
