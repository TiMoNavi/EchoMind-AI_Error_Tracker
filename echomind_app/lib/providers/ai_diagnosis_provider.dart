import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/core/api_client.dart';

class DiagnosisSession {
  final String sessionId;
  final String status;
  final List<Map<String, dynamic>> messages;

  const DiagnosisSession({
    this.sessionId = '',
    this.status = 'idle',
    this.messages = const [],
  });

  factory DiagnosisSession.fromJson(Map<String, dynamic> json) =>
      DiagnosisSession(
        sessionId: json['session_id'] ?? '',
        status: json['status'] ?? 'idle',
        messages: (json['messages'] as List?)
                ?.map((e) => Map<String, dynamic>.from(e))
                .toList() ??
            [],
      );
}

final aiDiagnosisProvider = FutureProvider<DiagnosisSession?>((ref) async {
  try {
    final res = await ApiClient().dio.get('/diagnosis/session');
    return DiagnosisSession.fromJson(res.data);
  } catch (_) {
    // 后端暂无此端点，返回 null 触发 demo 模式
    return null;
  }
});
