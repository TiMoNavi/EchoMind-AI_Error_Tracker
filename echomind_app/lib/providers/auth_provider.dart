import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:echomind_app/core/api_client.dart';
import 'package:echomind_app/models/student.dart';

class AuthState {
  final Student? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({Student? user, bool? isLoading, String? error}) =>
      AuthState(
        user: user ?? this.user,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  final _dio = ApiClient().dio;

  Future<bool> login(String phone, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _dio.post('/auth/login', data: {
        'phone': phone,
        'password': password,
      });
      final token = res.data['access_token'] as String;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);

      final user = Student.fromJson(res.data['user']);
      state = AuthState(user: user);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> register({
    required String phone,
    required String password,
    required String regionId,
    required String subject,
    required int targetScore,
    String? nickname,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _dio.post('/auth/register', data: {
        'phone': phone,
        'password': password,
        'region_id': regionId,
        'subject': subject,
        'target_score': targetScore,
        if (nickname != null) 'nickname': nickname,
      });
      final token = res.data['access_token'] as String;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);

      final user = Student.fromJson(res.data['user']);
      state = AuthState(user: user);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
