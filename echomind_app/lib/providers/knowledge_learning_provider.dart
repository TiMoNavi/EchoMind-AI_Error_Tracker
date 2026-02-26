import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/core/api_client.dart';

// ---------------------------------------------------------------------------
// Data models
// ---------------------------------------------------------------------------

class LearningMessage {
  final String id;
  final String role;
  final String content;
  final int step;
  final String createdAt;

  const LearningMessage({
    this.id = '',
    this.role = '',
    this.content = '',
    this.step = 1,
    this.createdAt = '',
  });

  factory LearningMessage.fromJson(Map<String, dynamic> json) =>
      LearningMessage(
        id: json['id']?.toString() ?? '',
        role: json['role'] ?? '',
        content: json['content'] ?? '',
        step: json['step'] ?? 1,
        createdAt: json['created_at'] ?? '',
      );
}

class LearningSession {
  final String sessionId;
  final String status;
  final String knowledgePointId;
  final String knowledgePointName;
  final int currentStep;
  final int maxSteps;
  final String source;
  final double? masteryBefore;
  final double? masteryAfter;
  final String? levelBefore;
  final String? levelAfter;
  final List<LearningMessage> messages;

  const LearningSession({
    this.sessionId = '',
    this.status = 'idle',
    this.knowledgePointId = '',
    this.knowledgePointName = '',
    this.currentStep = 1,
    this.maxSteps = 5,
    this.source = 'self_study',
    this.masteryBefore,
    this.masteryAfter,
    this.levelBefore,
    this.levelAfter,
    this.messages = const [],
  });

  factory LearningSession.fromJson(Map<String, dynamic> json) =>
      LearningSession(
        sessionId: json['session_id'] ?? '',
        status: json['status'] ?? 'idle',
        knowledgePointId: json['knowledge_point_id'] ?? '',
        knowledgePointName: json['knowledge_point_name'] ?? '',
        currentStep: json['current_step'] ?? 1,
        maxSteps: json['max_steps'] ?? 5,
        source: json['source'] ?? 'self_study',
        masteryBefore: (json['mastery_before'] as num?)?.toDouble(),
        masteryAfter: (json['mastery_after'] as num?)?.toDouble(),
        levelBefore: json['level_before'],
        levelAfter: json['level_after'],
        messages: (json['messages'] as List?)
                ?.map((e) => LearningMessage.fromJson(e))
                .toList() ??
            [],
      );

  LearningSession copyWith({
    String? sessionId,
    String? status,
    String? knowledgePointId,
    String? knowledgePointName,
    int? currentStep,
    int? maxSteps,
    String? source,
    double? masteryBefore,
    double? masteryAfter,
    String? levelBefore,
    String? levelAfter,
    List<LearningMessage>? messages,
  }) =>
      LearningSession(
        sessionId: sessionId ?? this.sessionId,
        status: status ?? this.status,
        knowledgePointId: knowledgePointId ?? this.knowledgePointId,
        knowledgePointName: knowledgePointName ?? this.knowledgePointName,
        currentStep: currentStep ?? this.currentStep,
        maxSteps: maxSteps ?? this.maxSteps,
        source: source ?? this.source,
        masteryBefore: masteryBefore ?? this.masteryBefore,
        masteryAfter: masteryAfter ?? this.masteryAfter,
        levelBefore: levelBefore ?? this.levelBefore,
        levelAfter: levelAfter ?? this.levelAfter,
        messages: messages ?? this.messages,
      );
}

// ---------------------------------------------------------------------------
// State wrapper
// ---------------------------------------------------------------------------

class KnowledgeLearningState {
  final LearningSession? session;
  final bool isLoading;
  final bool isSending;
  final String? error;

  const KnowledgeLearningState({
    this.session,
    this.isLoading = false,
    this.isSending = false,
    this.error,
  });

  KnowledgeLearningState copyWith({
    LearningSession? session,
    bool? isLoading,
    bool? isSending,
    String? error,
    bool clearError = false,
    bool clearSession = false,
  }) =>
      KnowledgeLearningState(
        session: clearSession ? null : (session ?? this.session),
        isLoading: isLoading ?? this.isLoading,
        isSending: isSending ?? this.isSending,
        error: clearError ? null : (error ?? this.error),
      );
}

// ---------------------------------------------------------------------------
// StateNotifier
// ---------------------------------------------------------------------------

class KnowledgeLearningNotifier extends StateNotifier<KnowledgeLearningState> {
  KnowledgeLearningNotifier() : super(const KnowledgeLearningState());

  final _dio = ApiClient().dio;

  /// POST /knowledge/learning/start
  Future<void> startSession(String knowledgePointId, {String source = 'self_study'}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final res = await _dio.post('/knowledge/learning/start', data: {
        'knowledge_point_id': knowledgePointId,
        'source': source,
      });
      final session = LearningSession.fromJson(res.data);
      state = state.copyWith(session: session, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// POST /knowledge/learning/chat
  Future<void> sendMessage(String content) async {
    final sid = state.session?.sessionId;
    if (sid == null || sid.isEmpty) return;

    // Optimistic: append user message immediately
    final userMsg = LearningMessage(
      id: 'tmp_${DateTime.now().millisecondsSinceEpoch}',
      role: 'user',
      content: content,
      step: state.session!.currentStep,
    );
    state = state.copyWith(
      session: state.session!.copyWith(
        messages: [...state.session!.messages, userMsg],
      ),
      isSending: true,
      clearError: true,
    );

    try {
      final res = await _dio.post('/knowledge/learning/chat', data: {
        'session_id': sid,
        'content': content,
      });
      final data = res.data as Map<String, dynamic>;
      final aiMsg = LearningMessage.fromJson(data['message']);
      final sessionInfo = data['session'] as Map<String, dynamic>;

      state = state.copyWith(
        session: state.session!.copyWith(
          messages: [...state.session!.messages, aiMsg],
          currentStep: sessionInfo['current_step'] ?? state.session!.currentStep,
          status: sessionInfo['status'] ?? state.session!.status,
        ),
        isSending: false,
      );
    } catch (e) {
      state = state.copyWith(isSending: false, error: e.toString());
    }
  }

  /// GET /knowledge/learning/session/{id}
  Future<void> loadSession(String sessionId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final res = await _dio.get('/knowledge/learning/session/$sessionId');
      final session = LearningSession.fromJson(res.data);
      state = state.copyWith(session: session, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// POST /knowledge/learning/complete
  Future<void> completeSession() async {
    final sid = state.session?.sessionId;
    if (sid == null || sid.isEmpty) return;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _dio.post('/knowledge/learning/complete', data: {
        'session_id': sid,
      });
      state = state.copyWith(
        session: state.session!.copyWith(status: 'expired'),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// 重置状态
  void reset() {
    state = const KnowledgeLearningState();
  }
}

// ---------------------------------------------------------------------------
// Provider definitions
// ---------------------------------------------------------------------------

final knowledgeLearningProvider =
    StateNotifierProvider<KnowledgeLearningNotifier, KnowledgeLearningState>(
  (ref) => KnowledgeLearningNotifier(),
);
