// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ModelItem _$ModelItemFromJson(Map<String, dynamic> json) => ModelItem(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
    );

ModelSectionNode _$ModelSectionNodeFromJson(Map<String, dynamic> json) =>
    ModelSectionNode(
      section: json['section'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => ModelItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

ModelChapterNode _$ModelChapterNodeFromJson(Map<String, dynamic> json) =>
    ModelChapterNode(
      chapter: json['chapter'] as String,
      sections: (json['sections'] as List<dynamic>)
          .map((e) => ModelSectionNode.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
