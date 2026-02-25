/// Data models for Community page.

class CommunityRequest {
  final String id;
  final String title;
  final String subtitle;
  final int votes;
  final List<String> tags;
  final String status; // 'open', 'planned', 'done'

  const CommunityRequest({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.votes,
    required this.tags,
    this.status = 'open',
  });

  factory CommunityRequest.fromJson(Map<String, dynamic> json) {
    return CommunityRequest(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      votes: json['votes'] as int,
      tags: (json['tags'] as List).cast<String>(),
      status: json['status'] as String? ?? 'open',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'votes': votes,
    'tags': tags,
    'status': status,
  };
}
