/// Data models for Knowledge Detail page.

class KnowledgeDetail {
  final String id;
  final String name;
  final String level;
  final String levelLabel;
  final String levelDescription;
  final int predictedGain;
  final List<String> tags;

  const KnowledgeDetail({
    required this.id,
    required this.name,
    required this.level,
    required this.levelLabel,
    required this.levelDescription,
    required this.predictedGain,
    required this.tags,
  });

  factory KnowledgeDetail.fromJson(Map<String, dynamic> json) {
    return KnowledgeDetail(
      id: json['id'] as String,
      name: json['name'] as String,
      level: json['level'] as String,
      levelLabel: json['level_label'] as String,
      levelDescription: json['level_description'] as String,
      predictedGain: json['predicted_gain'] as int,
      tags: (json['tags'] as List).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'level': level,
    'level_label': levelLabel,
    'level_description': levelDescription,
    'predicted_gain': predictedGain,
    'tags': tags,
  };
}

class ConceptTestRecord {
  final String id;
  final String date;
  final String score;
  final String status;

  const ConceptTestRecord({
    required this.id,
    required this.date,
    required this.score,
    required this.status,
  });

  factory ConceptTestRecord.fromJson(Map<String, dynamic> json) {
    return ConceptTestRecord(
      id: json['id'] as String,
      date: json['date'] as String,
      score: json['score'] as String,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date,
    'score': score,
    'status': status,
  };
}

class RelatedModel {
  final String id;
  final String name;
  final String level;
  final String subtitle;

  const RelatedModel({
    required this.id,
    required this.name,
    required this.level,
    required this.subtitle,
  });

  factory RelatedModel.fromJson(Map<String, dynamic> json) {
    return RelatedModel(
      id: json['id'] as String,
      name: json['name'] as String,
      level: json['level'] as String,
      subtitle: json['subtitle'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'level': level,
    'subtitle': subtitle,
  };
}
