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

  Future<bool> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _dio.post('/auth/login', data: {
        'username': username,
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

  Future<bool> register(String username, String password, {String? email}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _dio.post('/auth/register', data: {
        'username': username,
        'password': password,
        if (email != null) 'email': email,
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
