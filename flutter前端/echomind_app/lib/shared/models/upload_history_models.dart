/// Data models for Upload History page.

class UploadRecord {
  final String id;
  final String title;
  final String description;
  final String time;
  final String status; // 'diagnosed', 'pending', 'failed'
  final String type; // 'photo', 'text', 'file'

  const UploadRecord({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.status,
    required this.type,
  });

  factory UploadRecord.fromJson(Map<String, dynamic> json) {
    return UploadRecord(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      time: json['time'] as String,
      status: json['status'] as String,
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'time': time,
    'status': status,
    'type': type,
  };
}

class UploadDateGroup {
  final String date;
  final List<UploadRecord> records;

  const UploadDateGroup({
    required this.date,
    required this.records,
  });

  factory UploadDateGroup.fromJson(Map<String, dynamic> json) {
    return UploadDateGroup(
      date: json['date'] as String,
      records: (json['records'] as List)
          .map((e) => UploadRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date,
    'records': records.map((e) => e.toJson()).toList(),
  };
}
