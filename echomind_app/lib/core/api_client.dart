import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static const _baseUrl = 'http://localhost:8000/api';
  static const _tokenKey = 'auth_token';

  static final ApiClient _instance = ApiClient._();
  factory ApiClient() => _instance;

  late final Dio dio;

  ApiClient._() {
    dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: 'application/json',
    ));
    dio.interceptors.add(_AuthInterceptor());
    dio.interceptors.add(_ErrorInterceptor());
  }
}

/// Token 拦截器：自动附加 Authorization header
class _AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

/// 统一错误处理拦截器
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final message = switch (err.type) {
      DioExceptionType.connectionTimeout => '连接超时',
      DioExceptionType.receiveTimeout => '响应超时',
      DioExceptionType.badResponse => _parseServerError(err.response),
      DioExceptionType.connectionError => '无法连接服务器',
      _ => '网络错误: ${err.message}',
    };
    handler.next(err.copyWith(message: message));
  }

  String _parseServerError(Response? response) {
    if (response == null) return '服务器错误';
    final data = response.data;
    if (data is Map && data.containsKey('detail')) {
      return data['detail'].toString();
    }
    return '服务器错误 (${response.statusCode})';
  }
}
