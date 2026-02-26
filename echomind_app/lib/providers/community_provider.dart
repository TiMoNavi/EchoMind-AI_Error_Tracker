import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/core/api_client.dart';
import 'package:echomind_app/models/community.dart';

// --- State ---

class CommunityState {
  final bool isLoading;
  final bool isSubmitting;
  final List<FeatureRequest> requests;
  final List<Feedback> feedbacks;
  final int requestsTotal;
  final int feedbacksTotal;
  final String? errorMessage;

  const CommunityState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.requests = const [],
    this.feedbacks = const [],
    this.requestsTotal = 0,
    this.feedbacksTotal = 0,
    this.errorMessage,
  });

  CommunityState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    List<FeatureRequest>? requests,
    List<Feedback>? feedbacks,
    int? requestsTotal,
    int? feedbacksTotal,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CommunityState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      requests: requests ?? this.requests,
      feedbacks: feedbacks ?? this.feedbacks,
      requestsTotal: requestsTotal ?? this.requestsTotal,
      feedbacksTotal: feedbacksTotal ?? this.feedbacksTotal,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

// --- StateNotifier ---

class CommunityNotifier extends StateNotifier<CommunityState> {
  final ApiClient _api;
  CommunityNotifier(this._api) : super(const CommunityState());

  /// 加载需求列表
  Future<void> fetchRequests({int offset = 0, int limit = 20}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final res = await _api.dio.get(
        '/community/requests',
        queryParameters: {'offset': offset, 'limit': limit},
      );
      final data = res.data as Map<String, dynamic>;
      final items = (data['items'] as List)
          .map((e) => FeatureRequest.fromJson(e))
          .toList();
      state = state.copyWith(
        isLoading: false,
        requests: items,
        requestsTotal: data['total'] ?? 0,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: '$e');
    }
  }

  /// 提交新需求
  Future<bool> submitRequest({
    required String title,
    required String description,
    String? tag,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await _api.dio.post('/community/requests', data: {
        'title': title,
        'description': description,
        if (tag != null && tag.isNotEmpty) 'tag': tag,
      });
      state = state.copyWith(isSubmitting: false);
      await fetchRequests();
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: '$e');
      return false;
    }
  }

  /// 投票 / 取消投票
  Future<void> toggleVote(String requestId) async {
    final idx = state.requests.indexWhere((r) => r.id == requestId);
    if (idx == -1) return;
    final req = state.requests[idx];

    // 乐观更新
    final updated = req.copyWith(
      voted: !req.voted,
      voteCount: req.voted ? req.voteCount - 1 : req.voteCount + 1,
    );
    final newList = [...state.requests];
    newList[idx] = updated;
    state = state.copyWith(requests: newList);

    try {
      if (req.voted) {
        await _api.dio.delete('/community/requests/$requestId/vote');
      } else {
        await _api.dio.post('/community/requests/$requestId/vote');
      }
    } catch (e) {
      // 回滚
      final rollback = [...state.requests];
      rollback[idx] = req;
      state = state.copyWith(requests: rollback, errorMessage: '$e');
    }
  }

  /// 加载反馈列表
  Future<void> fetchFeedbacks({int offset = 0, int limit = 20}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final res = await _api.dio.get(
        '/community/feedback',
        queryParameters: {'offset': offset, 'limit': limit},
      );
      final data = res.data as Map<String, dynamic>;
      final items = (data['items'] as List)
          .map((e) => Feedback.fromJson(e))
          .toList();
      state = state.copyWith(
        isLoading: false,
        feedbacks: items,
        feedbacksTotal: data['total'] ?? 0,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: '$e');
    }
  }

  /// 提交反馈
  Future<bool> submitFeedback({
    required String content,
    required String feedbackType,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await _api.dio.post('/community/feedback', data: {
        'content': content,
        'feedback_type': feedbackType,
      });
      state = state.copyWith(isSubmitting: false);
      await fetchFeedbacks();
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: '$e');
      return false;
    }
  }
}

// --- Provider ---

final communityProvider =
    StateNotifierProvider<CommunityNotifier, CommunityState>((ref) {
  return CommunityNotifier(ApiClient());
});
