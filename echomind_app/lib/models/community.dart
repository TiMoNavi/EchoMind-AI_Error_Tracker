/// 社区功能数据模型

class FeatureRequest {
  final String id;
  final String title;
  final String description;
  final int voteCount;
  final String? tag;
  final String studentId;
  final bool voted;
  final DateTime createdAt;

  const FeatureRequest({
    required this.id,
    required this.title,
    required this.description,
    required this.voteCount,
    this.tag,
    required this.studentId,
    required this.voted,
    required this.createdAt,
  });

  factory FeatureRequest.fromJson(Map<String, dynamic> json) => FeatureRequest(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        voteCount: json['vote_count'] ?? 0,
        tag: json['tag'],
        studentId: json['student_id'] ?? '',
        voted: json['voted'] ?? false,
        createdAt:
            DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      );

  FeatureRequest copyWith({int? voteCount, bool? voted}) => FeatureRequest(
        id: id,
        title: title,
        description: description,
        voteCount: voteCount ?? this.voteCount,
        tag: tag,
        studentId: studentId,
        voted: voted ?? this.voted,
        createdAt: createdAt,
      );
}

class Feedback {
  final String id;
  final String content;
  final String feedbackType;
  final String studentId;
  final DateTime createdAt;

  const Feedback({
    required this.id,
    required this.content,
    required this.feedbackType,
    required this.studentId,
    required this.createdAt,
  });

  factory Feedback.fromJson(Map<String, dynamic> json) => Feedback(
        id: json['id'] ?? '',
        content: json['content'] ?? '',
        feedbackType: json['feedback_type'] ?? '',
        studentId: json['student_id'] ?? '',
        createdAt:
            DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      );
}
