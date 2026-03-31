import 'package:dio/dio.dart';
import 'package:soundtilo/core/constants/api_urls.dart';
import 'package:soundtilo/data/models/user_model.dart';

class UserRemoteDataSource {
  final Dio _dio;

  UserRemoteDataSource(this._dio);

  Future<UserModel> getProfile() async {
    final response = await _dio.get(ApiUrls.userProfile);
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserModel> updateProfile({
    String? displayName,
    String? avatarUrl,
  }) async {
    final response = await _dio.put(
      ApiUrls.userProfile,
      data: {
        if (displayName != null) 'displayName': displayName,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
      },
    );
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }
}
