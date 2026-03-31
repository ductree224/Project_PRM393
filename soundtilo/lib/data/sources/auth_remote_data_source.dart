import 'package:dio/dio.dart';
import 'package:soundtilo/core/constants/api_urls.dart';
import 'package:soundtilo/data/models/auth_response_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soundtilo/core/di/service_locator.dart';

class AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSource(this._dio);


  Future<AuthResponseModel> register({
    required String username,
    required String email,
    required String password,
    String? displayName,
  }) async {
    final response = await _dio.post(ApiUrls.register, data: {
      'username': username,
      'email': email,
      'password': password,
      'displayName': displayName,
    });
    return AuthResponseModel.fromJson(response.data);
  }

  Future<AuthResponseModel> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    final response = await _dio.post(ApiUrls.login, data: {
      'usernameOrEmail': usernameOrEmail,
      'password': password,
    });
    return AuthResponseModel.fromJson(response.data);
  }

  Future<AuthResponseModel> refreshToken(String refreshToken) async {
    final response = await _dio.post(ApiUrls.refreshToken, data: {
      'refreshToken': refreshToken,
    });
    return AuthResponseModel.fromJson(response.data);
  }

  Future<AuthResponseModel> googleLogin(String idToken) async {
    final response = await _dio.post(ApiUrls.googleLogin, data: {
      'idToken': idToken,
    });
    return AuthResponseModel.fromJson(response.data);
  }

  Future<String> forgotPassword(String email) async {
    final response = await _dio.post(ApiUrls.forgotPassword, data: {
      'email': email,
    });
    final token = response.data['token']?.toString();
    if (token == null || token.isEmpty) {
      throw const FormatException('Không nhận được mã đặt lại mật khẩu.');
    }
    return token;
  }

  Future<String> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    final response = await _dio.post(ApiUrls.resetPassword, data: {
      'token': token,
      'newPassword': newPassword,
    });
    return response.data['message']?.toString() ?? 'Đặt lại mật khẩu thành công.';
  }
  Future<void> updateProfile({required String displayName, String? avatarUrl}) async {
    // 1. Lấy token từ bộ nhớ tạm
    final token = sl<SharedPreferences>().getString('access_token');

    final response = await _dio.put(ApiUrls.userProfile,
      data: {
        'displayName': displayName,
        'avatarUrl': avatarUrl,
      },
      // 2. Gắn token vào Header gửi đi
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (response.statusCode != 200) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
      );
    }
  }

  Future<void> changePassword({required String oldPassword, required String newPassword}) async {
    // 1. Lấy token từ bộ nhớ tạm
    final token = sl<SharedPreferences>().getString('access_token');

    final response = await _dio.post(ApiUrls.changePassword,
      data: {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      },
      // 2. Gắn token vào Header gửi đi
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (response.statusCode != 200) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
      );
    }
  }
}
