/// Data models for Global pages (knowledge tree, model tree, exam).

class TreeNode {
  final String id;
  final String name;
  final String? level;
  final String? masteryStatus;
  final List<TreeNode> children;

  const TreeNode({
    required this.id,
    required this.name,
    this.level,
    this.masteryStatus,
    this.children = const [],
  });

  factory TreeNode.fromJson(Map<String, dynamic> json) {
    return TreeNode(
      id: json['id'] as String,
      name: json['name'] as String,
      level: json['level'] as String?,
      masteryStatus: json['mastery_status'] as String?,
      children: (json['children'] as List?)
              ?.map((e) => TreeNode.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'level': level,
    'mastery_status': masteryStatus,
    'children': children.map((e) => e.toJson()).toList(),
  };
}

class ExamRecord {
  final String id;
  final String examName;
  final String date;
  final int score;
  final int errorCount;

  const ExamRecord({
    required this.id,
    required this.examName,
    required this.date,
    required this.score,
    required this.errorCount,
  });

  factory ExamRecord.fromJson(Map<String, dynamic> json) {
    return ExamRecord(
      id: json['id'] as String,
      examName: json['exam_name'] as String,
      date: json['date'] as String,
      score: json['score'] as int,
      errorCount: json['error_count'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'exam_name': examName,
    'date': date,
    'score': score,
    'error_count': errorCount,
  };
}

class HeatmapQuestion {
  final int questionNum;
  final int frequency;
  final String masteryLevel;

  const HeatmapQuestion({
    required this.questionNum,
    required this.frequency,
    required this.masteryLevel,
  });

  factory HeatmapQuestion.fromJson(Map<String, dynamic> json) {
    return HeatmapQuestion(
      questionNum: json['question_num'] as int,
      frequency: json['frequency'] as int,
      masteryLevel: json['mastery_level'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'question_num': questionNum,
    'frequency': frequency,
    'mastery_level': masteryLevel,
  };
}
