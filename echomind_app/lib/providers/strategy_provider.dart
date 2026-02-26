import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/core/api_client.dart';

// ── 数据模型 ──────────────────────────────────────────────

class QuestionStrategy {
  final String questionRange;
  final int maxScore;
  final int targetScore;
  final String attitude; // must / try / skip
  final String note;
  final String displayText;

  const QuestionStrategy({
    required this.questionRange,
    required this.maxScore,
    required this.targetScore,
    required this.attitude,
    required this.note,
    required this.displayText,
  });

  factory QuestionStrategy.fromJson(Map<String, dynamic> json) =>
      QuestionStrategy(
        questionRange: json['question_range'] ?? '',
        maxScore: json['max_score'] ?? 0,
        targetScore: json['target_score'] ?? 0,
        attitude: json['attitude'] ?? 'try',
        note: json['note'] ?? '',
        displayText: json['display_text'] ?? '',
      );
}

class StrategyData {
  final int targetScore;
  final int totalScore;
  final String regionId;
  final String subject;
  final String templateId;
  final String? keyMessage;
  final String? vsLower;
  final String? vsHigher;
  final List<QuestionStrategy> questionStrategies;
  final String generatedAt;

  const StrategyData({
    required this.targetScore,
    required this.totalScore,
    required this.regionId,
    required this.subject,
    required this.templateId,
    this.keyMessage,
    this.vsLower,
    this.vsHigher,
    required this.questionStrategies,
    required this.generatedAt,
  });

  factory StrategyData.fromJson(Map<String, dynamic> json) => StrategyData(
        targetScore: json['target_score'] ?? 0,
        totalScore: json['total_score'] ?? 100,
        regionId: json['region_id'] ?? '',
        subject: json['subject'] ?? '',
        templateId: json['template_id'] ?? '',
        keyMessage: json['key_message'],
        vsLower: json['vs_lower'],
        vsHigher: json['vs_higher'],
        questionStrategies: (json['question_strategies'] as List?)
                ?.map((e) => QuestionStrategy.fromJson(e))
                .toList() ??
            [],
        generatedAt: json['generated_at'] ?? '',
      );
}

class AttitudeChange {
  final String questionRange;
  final String oldAttitude;
  final String newAttitude;

  const AttitudeChange({
    required this.questionRange,
    required this.oldAttitude,
    required this.newAttitude,
  });

  factory AttitudeChange.fromJson(Map<String, dynamic> json) => AttitudeChange(
        questionRange: json['question_range'] ?? '',
        oldAttitude: json['old_attitude'] ?? '',
        newAttitude: json['new_attitude'] ?? '',
      );
}

class StrategyChanges {
  final List<AttitudeChange> upgradedToMust;
  final List<AttitudeChange> downgraded;
  final String keyMessageDiff;

  const StrategyChanges({
    required this.upgradedToMust,
    required this.downgraded,
    required this.keyMessageDiff,
  });

  factory StrategyChanges.fromJson(Map<String, dynamic> json) =>
      StrategyChanges(
        upgradedToMust: (json['upgraded_to_must'] as List?)
                ?.map((e) => AttitudeChange.fromJson(e))
                .toList() ??
            [],
        downgraded: (json['downgraded'] as List?)
                ?.map((e) => AttitudeChange.fromJson(e))
                .toList() ??
            [],
        keyMessageDiff: json['key_message_diff'] ?? '',
      );
}

// ── State ─────────────────────────────────────────────────

class StrategyState {
  final bool isLoading;
  final bool hasStrategy;
  final StrategyData? strategy;
  final List<int> availableScores;
  final String? errorMessage;

  const StrategyState({
    this.isLoading = false,
    this.hasStrategy = false,
    this.strategy,
    this.availableScores = const [],
    this.errorMessage,
  });

  StrategyState copyWith({
    bool? isLoading,
    bool? hasStrategy,
    StrategyData? strategy,
    List<int>? availableScores,
    String? errorMessage,
  }) =>
      StrategyState(
        isLoading: isLoading ?? this.isLoading,
        hasStrategy: hasStrategy ?? this.hasStrategy,
        strategy: strategy ?? this.strategy,
        availableScores: availableScores ?? this.availableScores,
        errorMessage: errorMessage,
      );
}

// ── Notifier ──────────────────────────────────────────────

class StrategyNotifier extends StateNotifier<StrategyState> {
  final ApiClient _api;

  StrategyNotifier(this._api) : super(const StrategyState());

  /// 获取当前策略
  Future<void> fetchStrategy() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final res = await _api.dio.get('/strategy');
      final data = res.data as Map<String, dynamic>;
      final has = data['has_strategy'] == true;
      state = state.copyWith(
        isLoading: false,
        hasStrategy: has,
        strategy:
            has && data['strategy'] != null ? StrategyData.fromJson(data['strategy']) : null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// 获取可用分数档
  Future<void> fetchTemplates() async {
    try {
      final res = await _api.dio.get('/strategy/templates');
      final scores = (res.data['available_scores'] as List?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [];
      state = state.copyWith(availableScores: scores);
    } catch (_) {}
  }

  /// 生成策略
  Future<void> generateStrategy({int? targetScore}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final body = <String, dynamic>{};
      if (targetScore != null) body['target_score'] = targetScore;
      final res = await _api.dio.post('/strategy/generate', data: body);
      final strategy = StrategyData.fromJson(res.data);
      state = state.copyWith(
        isLoading: false,
        hasStrategy: true,
        strategy: strategy,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// 修改目标分数并重新生成
  Future<StrategyChanges?> updateTargetScore(int newScore) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final res = await _api.dio.put(
        '/strategy/target-score',
        data: {'new_target_score': newScore},
      );
      final data = res.data as Map<String, dynamic>;
      final strategy = StrategyData.fromJson(data['strategy']);
      final changes = StrategyChanges.fromJson(data['changes']);
      state = state.copyWith(
        isLoading: false,
        hasStrategy: true,
        strategy: strategy,
      );
      return changes;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return null;
    }
  }
}

// ── Provider ──────────────────────────────────────────────

final strategyProvider =
    StateNotifierProvider<StrategyNotifier, StrategyState>((ref) {
  return StrategyNotifier(ApiClient());
});
