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
    String? subscriptionTier,
  }) async {
    final normalizedSearch = search?.trim();
    final normalizedRole = role?.trim();
    final normalizedTier = subscriptionTier?.trim();

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
      'subscriptionTier': (normalizedTier != null && normalizedTier.isNotEmpty)
          ? normalizedTier
          : null,
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

  Future<void> grantPremium(String userId, {DateTime? expiresAt}) async {
    await _dio.post(
      ApiUrls.adminGrantPremium(userId),
      data: {'expiresAt': expiresAt?.toUtc().toIso8601String()},
    );
  }

  Future<void> revokePremium(String userId) async {
    await _dio.delete(ApiUrls.adminRevokePremium(userId));
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

  // ─── Dashboard ────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getDashboardSummary() async {
    final response = await _dio.get(ApiUrls.adminDashboardSummary);
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> getDashboardUserGrowth({String? month}) async {
    final params = <String, dynamic>{};
    if (month != null && month.isNotEmpty) params['month'] = month;
    final response = await _dio.get(
      ApiUrls.adminDashboardUserGrowth,
      queryParameters: params.isEmpty ? null : params,
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> getDashboardPlayTrend({String? month}) async {
    final params = <String, dynamic>{};
    if (month != null && month.isNotEmpty) params['month'] = month;
    final response = await _dio.get(
      ApiUrls.adminDashboardPlayTrend,
      queryParameters: params.isEmpty ? null : params,
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> getDashboardTopTracks({
    String? month,
    int limit = 10,
  }) async {
    final params = <String, dynamic>{'limit': limit};
    if (month != null && month.isNotEmpty) params['month'] = month;
    final response = await _dio.get(
      ApiUrls.adminDashboardTopTracks,
      queryParameters: params,
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  // ─── Analytics ────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getAnalyticsOverview() async {
    final response = await _dio.get(ApiUrls.adminAnalyticsOverview);
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<List<dynamic>> getAnalyticsTopTracks({int count = 10}) async {
    final response = await _dio.get(
      ApiUrls.adminAnalyticsTopTracks,
      queryParameters: {'count': count},
    );
    return response.data as List<dynamic>;
  }

  Future<List<dynamic>> getAnalyticsDailyStats({
    String? from,
    String? to,
  }) async {
    final params = <String, dynamic>{};
    if (from != null && from.isNotEmpty) params['from'] = from;
    if (to != null && to.isNotEmpty) params['to'] = to;
    final response = await _dio.get(
      ApiUrls.adminAnalyticsDailyStats,
      queryParameters: params.isEmpty ? null : params,
    );
    return response.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> getSubscriptionStats() async {
    final response = await _dio.get(ApiUrls.adminSubscriptionStats);
    return Map<String, dynamic>.from(response.data as Map);
  }
}
