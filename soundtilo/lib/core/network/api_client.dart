import 'package:dio/dio.dart';
import 'package:soundtilo/core/constants/api_urls.dart';
import 'package:soundtilo/domain/repository/auth_repository.dart';

class ApiClient {
  final Dio dio;
  final AuthRepository _authRepository;

  ApiClient(this._authRepository)
      : dio = Dio(BaseOptions(
          baseUrl: ApiUrls.baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        )) {
    dio.interceptors.add(_AuthInterceptor(_authRepository, dio));
  }
}

class _AuthInterceptor extends Interceptor {
  final AuthRepository _authRepository;
  final Dio _dio;
  bool _isRefreshing = false;

  _AuthInterceptor(this._authRepository, this._dio);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // Skip auth for public endpoints
    final publicPaths = [
      ApiUrls.login,
      ApiUrls.register,
      ApiUrls.refreshToken,
    ];
    if (publicPaths.any((path) => options.path.contains(path))) {
      return handler.next(options);
    }

    final token = await _authRepository.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;
      try {
        // Lấy refresh token từ local storage
        final refreshTokenValue = await _authRepository.getRefreshToken();
        if (refreshTokenValue != null) {
          // Gọi API refresh
          final result = await _authRepository.refreshToken(refreshTokenValue);
          await result.fold(
            (_) async {
              // Refresh thất bại → logout
              await _authRepository.logout();
            },
            (_) async {
              // Refresh thành công → retry request gốc với token mới
              final newToken = await _authRepository.getAccessToken();
              if (newToken != null) {
                err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
                final response = await _dio.fetch(err.requestOptions);
                _isRefreshing = false;
                return handler.resolve(response);
              }
            },
          );
        } else {
          await _authRepository.logout();
        }
      } catch (_) {
        await _authRepository.logout();
      }
      _isRefreshing = false;
    }
    return handler.next(err);
  }
}
