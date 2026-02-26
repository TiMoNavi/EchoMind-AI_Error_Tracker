import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/core/api_client.dart';

// ── 数据模型 ──────────────────────────────────────────────

class TrainingMessage {
  final String id;
  final String role; // 'user' | 'assistant'
  final String content;
  final int step;
  final String? createdAt;

  const TrainingMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.step,
    this.createdAt,
  });

  factory TrainingMessage.fromJson(Map<String, dynamic> json) =>
      TrainingMessage(
        id: json['id']?.toString() ?? '',
        role: json['role'] ?? 'assistant',
        content: json['content'] ?? '',
        step: json['step'] ?? 1,
        createdAt: json['created_at'],
      );
}

class StepResult {
  final int step;
  final bool passed;
  final String aiSummary;
  final Map<String, dynamic>? details;

  const StepResult({
    required this.step,
    required this.passed,
    this.aiSummary = '',
    this.details,
  });

  factory StepResult.fromJson(Map<String, dynamic> json) => StepResult(
        step: json['step'] ?? 0,
        passed: json['passed'] ?? false,
        aiSummary: json['ai_summary'] ?? '',
        details: json['details'],
      );
}

class NextStepHint {
  final int nextStep;
  final String stepName;
  final bool autoAdvance;

  const NextStepHint({
    required this.nextStep,
    this.stepName = '',
    this.autoAdvance = false,
  });

  factory NextStepHint.fromJson(Map<String, dynamic> json) => NextStepHint(
        nextStep: json['next_step'] ?? 0,
        stepName: json['step_name'] ?? '',
        autoAdvance: json['auto_advance'] ?? false,
      );
}

class MasteryUpdate {
  final int previousLevel;
  final int newLevel;
  final double previousValue;
  final double newValue;

  const MasteryUpdate({
    this.previousLevel = 0,
    this.newLevel = 0,
    this.previousValue = 0,
    this.newValue = 0,
  });

  factory MasteryUpdate.fromJson(Map<String, dynamic> json) => MasteryUpdate(
        previousLevel: json['previous_level'] ?? 0,
        newLevel: json['new_level'] ?? 0,
        previousValue: (json['previous_value'] ?? 0).toDouble(),
        newValue: (json['new_value'] ?? 0).toDouble(),
      );
}

class TrainingResult {
  final List<int> stepsCompleted;
  final List<int> stepsPassed;
  final MasteryUpdate masteryUpdate;
  final String? nextRetestDate;
  final String aiSummary;

  const TrainingResult({
    this.stepsCompleted = const [],
    this.stepsPassed = const [],
    this.masteryUpdate = const MasteryUpdate(),
    this.nextRetestDate,
    this.aiSummary = '',
  });

  factory TrainingResult.fromJson(Map<String, dynamic> json) => TrainingResult(
        stepsCompleted: (json['steps_completed'] as List?)
                ?.map((e) => e as int)
                .toList() ??
            [],
        stepsPassed: (json['steps_passed'] as List?)
                ?.map((e) => e as int)
                .toList() ??
            [],
        masteryUpdate: json['mastery_update'] != null
            ? MasteryUpdate.fromJson(json['mastery_update'])
            : const MasteryUpdate(),
        nextRetestDate: json['next_retest_date'],
        aiSummary: json['ai_summary'] ?? '',
      );
}

// ── 状态类 ──────────────────────────────────────────────

class TrainingState {
  final bool isLoading;
  final bool isSending;
  final String? sessionId;
  final String modelId;
  final String modelName;
  final String status; // 'idle' | 'active' | 'completed' | 'expired'
  final int currentStep; // 1-6
  final int entryStep;
  final List<TrainingMessage> messages;
  final Map<int, StepResult> stepResults;
  final TrainingResult? trainingResult;
  final String? stepStatus; // 'in_progress' | 'completed'
  final NextStepHint? nextStepHint;
  final String? errorMessage;

  const TrainingState({
    this.isLoading = false,
    this.isSending = false,
    this.sessionId,
    this.modelId = '',
    this.modelName = '',
    this.status = 'idle',
    this.currentStep = 1,
    this.entryStep = 1,
    this.messages = const [],
    this.stepResults = const {},
    this.trainingResult,
    this.stepStatus,
    this.nextStepHint,
    this.errorMessage,
  });

  bool get isActive => status == 'active';
  bool get isCompleted => status == 'completed';
  bool get hasSession => sessionId != null;
  bool get canSend => isActive && !isSending;
  bool get canAdvance => stepStatus == 'completed' && isActive;

  TrainingState copyWith({
    bool? isLoading,
    bool? isSending,
    String? sessionId,
    String? modelId,
    String? modelName,
    String? status,
    int? currentStep,
    int? entryStep,
    List<TrainingMessage>? messages,
    Map<int, StepResult>? stepResults,
    TrainingResult? trainingResult,
    String? stepStatus,
    NextStepHint? nextStepHint,
    String? errorMessage,
    bool clearError = false,
    bool clearResult = false,
    bool clearNextHint = false,
  }) {
    return TrainingState(
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      sessionId: sessionId ?? this.sessionId,
      modelId: modelId ?? this.modelId,
      modelName: modelName ?? this.modelName,
      status: status ?? this.status,
      currentStep: currentStep ?? this.currentStep,
      entryStep: entryStep ?? this.entryStep,
      messages: messages ?? this.messages,
      stepResults: stepResults ?? this.stepResults,
      trainingResult: clearResult ? null : (trainingResult ?? this.trainingResult),
      stepStatus: stepStatus ?? this.stepStatus,
      nextStepHint: clearNextHint ? null : (nextStepHint ?? this.nextStepHint),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

// ── Notifier ──────────────────────────────────────────────

class TrainingNotifier extends StateNotifier<TrainingState> {
  final ApiClient _api;

  TrainingNotifier(this._api) : super(const TrainingState());

  /// 解析会话 JSON → 更新 state
  void _applySession(Map<String, dynamic> json) {
    final msgs = (json['messages'] as List?)
            ?.map((e) => TrainingMessage.fromJson(e))
            .toList() ??
        [];

    final stepResultsList = (json['step_results'] as List?) ?? [];
    final stepMap = <int, StepResult>{};
    for (final sr in stepResultsList) {
      final r = StepResult.fromJson(sr);
      stepMap[r.step] = r;
    }

    TrainingResult? result;
    if (json['training_result'] != null) {
      result = TrainingResult.fromJson(json['training_result']);
    }

    state = state.copyWith(
      sessionId: json['session_id']?.toString(),
      modelId: json['model_id']?.toString() ?? '',
      modelName: json['model_name'] ?? '',
      status: json['status'] ?? 'active',
      currentStep: json['current_step'] ?? 1,
      entryStep: json['entry_step'] ?? 1,
      messages: msgs,
      stepResults: stepMap,
      trainingResult: result,
      isLoading: false,
      clearError: true,
    );
  }

  /// GET /models/training/session — 获取当前活跃训练会话
  Future<void> fetchActiveSession() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final res = await _api.dio.get('/models/training/session');
      if (res.data == null || (res.data is Map && res.data.isEmpty)) {
        state = state.copyWith(isLoading: false, status: 'idle');
        return;
      }
      _applySession(res.data);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '获取训练会话失败：$e',
      );
    }
  }

  /// GET /models/training/session/{id} — 获取指定会话详情
  Future<void> fetchSession(String sessionId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final res = await _api.dio.get('/models/training/session/$sessionId');
      _applySession(res.data);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '获取会话详情失败：$e',
      );
    }
  }

  /// POST /models/training/start — 创建训练会话
  Future<void> startSession({
    required String modelId,
    String source = 'self_study',
    String? questionId,
    Map<String, dynamic>? diagnosisResult,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final body = <String, dynamic>{
        'model_id': modelId,
        'source': source,
      };
      if (questionId != null) body['question_id'] = questionId;
      if (diagnosisResult != null) body['diagnosis_result'] = diagnosisResult;

      final res = await _api.dio.post('/models/training/start', data: body);
      _applySession(res.data);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '创建训练会话失败：$e',
      );
    }
  }

  /// POST /models/training/interact — 步内交互（乐观插入）
  Future<void> sendMessage(String content) async {
    if (!state.canSend) return;

    // 乐观插入用户消息
    final userMsg = TrainingMessage(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      role: 'user',
      content: content,
      step: state.currentStep,
    );
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isSending: true,
      clearError: true,
    );

    try {
      final res = await _api.dio.post('/models/training/interact', data: {
        'session_id': state.sessionId,
        'content': content,
      });

      final data = res.data as Map<String, dynamic>;

      // 解析 AI 回复
      final aiMsg = TrainingMessage.fromJson(data['message']);
      final newStepStatus = data['step_status'] as String?;

      // 解析可能的 step_result
      var newStepResults = Map<int, StepResult>.from(state.stepResults);
      if (data['step_result'] != null) {
        final sr = StepResult.fromJson(data['step_result']);
        newStepResults[sr.step] = sr;
      }

      // 解析可能的 next_step_hint
      NextStepHint? hint;
      if (data['next_step_hint'] != null) {
        hint = NextStepHint.fromJson(data['next_step_hint']);
      }

      state = state.copyWith(
        messages: [...state.messages, aiMsg],
        isSending: false,
        stepStatus: newStepStatus,
        stepResults: newStepResults,
        nextStepHint: hint,
      );
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        errorMessage: '发送失败：$e',
      );
    }
  }

  /// POST /models/training/next-step — 进入下一步
  Future<void> nextStep() async {
    if (!state.canAdvance) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final res = await _api.dio.post('/models/training/next-step', data: {
        'session_id': state.sessionId,
      });

      final data = res.data as Map<String, dynamic>;
      final session = data['session'] as Map<String, dynamic>?;

      // 训练完成
      if (session?['status'] == 'completed' && data['training_result'] != null) {
        final result = TrainingResult.fromJson(data['training_result']);
        state = state.copyWith(
          status: 'completed',
          currentStep: session?['current_step'] ?? state.currentStep,
          trainingResult: result,
          isLoading: false,
          stepStatus: null,
          clearNextHint: true,
        );
        return;
      }

      // 进入下一步：追加新消息
      final newMsgs = (data['messages'] as List?)
              ?.map((e) => TrainingMessage.fromJson(e))
              .toList() ??
          [];

      state = state.copyWith(
        currentStep: session?['current_step'] ?? state.currentStep,
        status: session?['status'] ?? 'active',
        messages: [...state.messages, ...newMsgs],
        isLoading: false,
        stepStatus: 'in_progress',
        clearNextHint: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '进入下一步失败：$e',
      );
    }
  }

  /// POST /models/training/complete — 手动结束训练
  Future<void> completeSession() async {
    if (state.sessionId == null) return;
    try {
      await _api.dio.post('/models/training/complete', data: {
        'session_id': state.sessionId,
      });
      state = state.copyWith(status: 'expired');
    } catch (e) {
      state = state.copyWith(errorMessage: '结束训练失败：$e');
    }
  }

  /// 重置状态
  void reset() => state = const TrainingState();
}

// ── Provider 定义 ──────────────────────────────────────────

final trainingProvider =
    StateNotifierProvider<TrainingNotifier, TrainingState>((ref) {
  return TrainingNotifier(ApiClient());
});
