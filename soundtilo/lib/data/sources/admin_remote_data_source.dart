import 'package:dio/dio.dart';
import 'package:soundtilo/core/constants/api_urls.dart';

class AdminRemoteDataSource {
  final Dio _dio;

  AdminRemoteDataSource(this._dio);

  Future<Map<String, dynamic>> getUsers({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? role,
    bool? isBanned,
  }) async {
    final normalizedSearch = search?.trim();
    final normalizedRole = role?.trim();

    final queryParameters = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
      'search': (normalizedSearch != null && normalizedSearch.isNotEmpty)
          ? normalizedSearch
          : null,
      'role': (normalizedRole != null && normalizedRole.isNotEmpty)
          ? normalizedRole
          : null,
      'isBanned': isBanned,
    };

    queryParameters.removeWhere((_, value) => value == null);

    final response = await _dio.get(
      ApiUrls.adminUsers,
      queryParameters: queryParameters,
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<void> banUser(String userId, {String? reason}) async {
    await _dio.post(ApiUrls.adminBanUser(userId), data: {'reason': reason});
  }

  Future<void> unbanUser(String userId) async {
    await _dio.post(ApiUrls.adminUnbanUser(userId));
  }

  Future<void> changeUserRole(String userId, String role) async {
    await _dio.put(ApiUrls.adminChangeUserRole(userId), data: {'role': role});
  }

  Future<void> deleteUser(String userId) async {
    await _dio.delete(ApiUrls.adminUserById(userId));
  }

  Future<Map<String, dynamic>> getUserHistory(
    String userId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get(
      ApiUrls.adminUserHistory(userId),
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> getUserFavorites(
    String userId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get(
      ApiUrls.adminUserFavorites(userId),
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> getUserPlaylists(
    String userId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get(
      ApiUrls.adminUserPlaylists(userId),
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    return Map<String, dynamic>.from(response.data as Map);
  }
}
