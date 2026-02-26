import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:echomind_app/core/api_client.dart';
import 'package:echomind_app/models/student.dart';

/// Profile 状态
class ProfileState {
  final Student? student;
  final bool loading;
  final bool uploading;
  final String? error;

  const ProfileState({this.student, this.loading = false, this.uploading = false, this.error});

  ProfileState copyWith({Student? student, bool? loading, bool? uploading, String? error}) =>
      ProfileState(
        student: student ?? this.student,
        loading: loading ?? this.loading,
        uploading: uploading ?? this.uploading,
        error: error,
      );
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier() : super(const ProfileState(loading: true)) {
    loadProfile();
  }

  final _api = ApiClient().dio;
  static const _baseHost = 'http://8.130.16.212:8001';

  /// 加载用户信息
  Future<void> loadProfile() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final res = await _api.get('/auth/me');
      state = state.copyWith(student: Student.fromJson(res.data), loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: '加载失败: $e');
    }
  }

  /// 上传头像图片并更新 profile
  Future<void> uploadAvatar(XFile image) async {
    state = state.copyWith(uploading: true, error: null);
    try {
      // 1) 上传图片
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(image.path, filename: image.name),
      });
      final uploadRes = await _api.post('/upload/image', data: formData);
      final relativeUrl = uploadRes.data['image_url'] as String;
      final fullUrl = '$_baseHost$relativeUrl';

      // 2) 更新 profile avatar_url
      await _api.put('/auth/profile', data: {'avatar_url': fullUrl});

      // 3) 乐观更新本地状态
      if (state.student != null) {
        state = state.copyWith(
          uploading: false,
          student: Student(
            id: state.student!.id,
            phone: state.student!.phone,
            nickname: state.student!.nickname,
            regionId: state.student!.regionId,
            subject: state.student!.subject,
            targetScore: state.student!.targetScore,
            predictedScore: state.student!.predictedScore,
            avatarUrl: fullUrl,
          ),
        );
      } else {
        state = state.copyWith(uploading: false);
        await loadProfile();
      }
    } catch (e) {
      state = state.copyWith(uploading: false, error: '头像上传失败: $e');
    }
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier();
});
