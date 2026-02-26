import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/core/api_client.dart';

// --- Data Models ---

class DiagnosisMessage {
  final String id;
  final String role; // 'user' | 'assistant' | 'system'
  final String content;
  final int round;
  final DateTime createdAt;

  const DiagnosisMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.round,
    required this.createdAt,
  });

  factory DiagnosisMessage.fromJson(Map<String, dynamic> json) =>
      DiagnosisMessage(
        id: json['id'] ?? '',
        role: json['role'] ?? 'assistant',
        content: json['content'] ?? '',
        round: json['round'] ?? 0,
        createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      );
}

class FourLayer {
  final String modeling;
  final String equation;
  final String execution;
  final String bottleneckLayer;
  final String bottleneckDetail;

  const FourLayer({
    this.modeling = '',
    this.equation = '',
    this.execution = '',
    this.bottleneckLayer = '',
    this.bottleneckDetail = '',
  });

  factory FourLayer.fromJson(Map<String, dynamic> json) => FourLayer(
        modeling: json['modeling'] ?? '',
        equation: json['equation'] ?? '',
        execution: json['execution'] ?? '',
        bottleneckLayer: json['bottleneck_layer'] ?? '',
        bottleneckDetail: json['bottleneck_detail'] ?? '',
      );
}

class Evidence5W {
  final String whatDescription;
  final String whenStage;
  final String rootCauseId;
  final String aiExplanation;
  final String confidence;

  const Evidence5W({
    this.whatDescription = '',
    this.whenStage = '',
    this.rootCauseId = '',
    this.aiExplanation = '',
    this.confidence = '',
  });

  factory Evidence5W.fromJson(Map<String, dynamic> json) => Evidence5W(
        whatDescription: json['what_description'] ?? '',
        whenStage: json['when_stage'] ?? '',
        rootCauseId: json['root_cause_id'] ?? '',
        aiExplanation: json['ai_explanation'] ?? '',
        confidence: json['confidence'] ?? '',
      );
}

class NextAction {
  final String type;
  final String targetId;
  final String message;

  const NextAction({this.type = '', this.targetId = '', this.message = ''});

  factory NextAction.fromJson(Map<String, dynamic> json) => NextAction(
        type: json['type'] ?? '',
        targetId: json['target_id'] ?? '',
        message: json['message'] ?? '',
      );
}

class DiagnosisResult {
  final FourLayer fourLayer;
  final String rootCategory;
  final String rootSubcategory;
  final Evidence5W evidence5w;
  final NextAction nextAction;

  const DiagnosisResult({
    this.fourLayer = const FourLayer(),
    this.rootCategory = '',
    this.rootSubcategory = '',
    this.evidence5w = const Evidence5W(),
    this.nextAction = const NextAction(),
  });

  factory DiagnosisResult.fromJson(Map<String, dynamic> json) =>
      DiagnosisResult(
        fourLayer: json['four_layer'] != null
            ? FourLayer.fromJson(json['four_layer'])
            : const FourLayer(),
        rootCategory: json['root_category'] ?? '',
        rootSubcategory: json['root_subcategory'] ?? '',
        evidence5w: json['evidence_5w'] != null
            ? Evidence5W.fromJson(json['evidence_5w'])
            : const Evidence5W(),
        nextAction: json['next_action'] != null
            ? NextAction.fromJson(json['next_action'])
            : const NextAction(),
      );
}

// --- State ---

class DiagnosisState {
  final bool isLoading;
  final bool isSending;
  final String? sessionId;
  final String? questionId;
  final String status; // 'idle' | 'active' | 'completed' | 'expired'
  final int round;
  final int maxRounds;
  final List<DiagnosisMessage> messages;
  final DiagnosisResult? diagnosisResult;
  final String? errorMessage;

  const DiagnosisState({
    this.isLoading = false,
    this.isSending = false,
    this.sessionId,
    this.questionId,
    this.status = 'idle',
    this.round = 0,
    this.maxRounds = 5,
    this.messages = const [],
    this.diagnosisResult,
    this.errorMessage,
  });

  bool get isActive => status == 'active';
  bool get isCompleted => status == 'completed';
  bool get isExpired => status == 'expired';
  bool get hasSession => sessionId != null;
  bool get canSend => isActive && !isSending;

  DiagnosisState copyWith({
    bool? isLoading,
    bool? isSending,
    String? sessionId,
    String? questionId,
    String? status,
    int? round,
    int? maxRounds,
    List<DiagnosisMessage>? messages,
    DiagnosisResult? diagnosisResult,
    String? errorMessage,
    bool clearError = false,
    bool clearResult = false,
  }) {
    return DiagnosisState(
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      sessionId: sessionId ?? this.sessionId,
      questionId: questionId ?? this.questionId,
      status: status ?? this.status,
      round: round ?? this.round,
      maxRounds: maxRounds ?? this.maxRounds,
      messages: messages ?? this.messages,
      diagnosisResult:
          clearResult ? null : (diagnosisResult ?? this.diagnosisResult),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

// --- StateNotifier ---

class DiagnosisNotifier extends StateNotifier<DiagnosisState> {
  final ApiClient _api;
  DiagnosisNotifier(this._api) : super(const DiagnosisState());

  /// 解析会话 JSON 并更新 state
  void _applySession(Map<String, dynamic> json) {
    final msgs = (json['messages'] as List?)
            ?.map((e) => DiagnosisMessage.fromJson(e))
            .toList() ??
        [];
    DiagnosisResult? result;
    if (json['diagnosis_result'] != null) {
      result = DiagnosisResult.fromJson(json['diagnosis_result']);
    }
    state = state.copyWith(
      sessionId: json['session_id'],
      questionId: json['question_id'],
      status: json['status'] ?? 'active',
      round: json['round'] ?? 0,
      maxRounds: json['max_rounds'] ?? 5,
      messages: msgs,
      diagnosisResult: result,
      isLoading: false,
      isSending: false,
      clearError: true,
    );
  }

  /// 获取当前活跃会话
  Future<void> fetchActiveSession() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final res = await _api.dio.get('/diagnosis/session');
      if (res.data == null) {
        state = state.copyWith(isLoading: false, status: 'idle');
        return;
      }
      _applySession(res.data);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: '$e');
    }
  }

  /// 开始新诊断会话
  Future<void> startSession({required String questionId}) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearResult: true,
    );
    try {
      final res = await _api.dio.post(
        '/diagnosis/start',
        data: {'question_id': questionId},
      );
      _applySession(res.data);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: '$e');
    }
  }

  /// 发送消息并获取 AI 回复
  Future<void> sendMessage(String content) async {
    if (!state.canSend || state.sessionId == null) return;

    // 乐观插入用户消息
    final userMsg = DiagnosisMessage(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      role: 'user',
      content: content,
      round: state.round,
      createdAt: DateTime.now(),
    );
    state = state.copyWith(
      isSending: true,
      messages: [...state.messages, userMsg],
      clearError: true,
    );

    try {
      final res = await _api.dio.post(
        '/diagnosis/chat',
        data: {'session_id': state.sessionId, 'content': content},
      );
      final data = res.data as Map<String, dynamic>;
      final aiMsg = DiagnosisMessage.fromJson(data['message']);
      final session = data['session'] as Map<String, dynamic>;

      DiagnosisResult? result;
      if (data['diagnosis_result'] != null) {
        result = DiagnosisResult.fromJson(data['diagnosis_result']);
      }

      state = state.copyWith(
        isSending: false,
        messages: [...state.messages, aiMsg],
        status: session['status'] ?? state.status,
        round: session['round'] ?? state.round,
        diagnosisResult: result,
      );
    } catch (e) {
      state = state.copyWith(isSending: false, errorMessage: '$e');
    }
  }

  /// 手动结束会话
  Future<void> completeSession() async {
    if (state.sessionId == null) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _api.dio.post(
        '/diagnosis/complete',
        data: {'session_id': state.sessionId},
      );
      state = state.copyWith(isLoading: false, status: 'expired');
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: '$e');
    }
  }

  /// 重置状态（开始新诊断前）
  void reset() {
    state = const DiagnosisState();
  }
}

// --- Provider ---

final diagnosisProvider =
    StateNotifierProvider<DiagnosisNotifier, DiagnosisState>((ref) {
  return DiagnosisNotifier(ApiClient());
});