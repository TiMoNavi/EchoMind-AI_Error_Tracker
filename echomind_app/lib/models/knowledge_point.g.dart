// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'knowledge_point.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KnowledgePointItem _$KnowledgePointItemFromJson(Map<String, dynamic> json) =>
    KnowledgePointItem(
      id: json['id'] as String,
      name: json['name'] as String,
      conclusionLevel: (json['conclusion_level'] as num).toInt(),
      description: json['description'] as String?,
    );

SectionNode _$SectionNodeFromJson(Map<String, dynamic> json) => SectionNode(
      section: json['section'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => KnowledgePointItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

ChapterNode _$ChapterNodeFromJson(Map<String, dynamic> json) => ChapterNode(
      chapter: json['chapter'] as String,
      sections: (json['sections'] as List<dynamic>)
          .map((e) => SectionNode.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
