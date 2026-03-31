import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:soundtilo/data/models/admin_user_model.dart';
import 'package:soundtilo/data/sources/admin_remote_data_source.dart';
import 'package:soundtilo/domain/entities/admin_analytics_entity.dart';
import 'package:soundtilo/domain/entities/admin_dashboard_entity.dart';
import 'package:soundtilo/domain/entities/admin_user_entity.dart';
import 'package:soundtilo/domain/repository/admin_repository.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource _remoteDataSource;

  AdminRepositoryImpl(this._remoteDataSource);

  String _extractDioErrorMessage(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map) {
      final dynamic message = data['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    }
    if (data is String && data.trim().isNotEmpty) {
      return data;
    }
    return fallback;
  }

  @override
  Future<Either<String, AdminUserListEntity>> getUsers({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? role,
    bool? isBanned,
    String? subscriptionTier,
  }) async {
    try {
      final data = await _remoteDataSource.getUsers(
        page: page,
        pageSize: pageSize,
        search: search,
        role: role,
        isBanned: isBanned,
        subscriptionTier: subscriptionTier,
      );

      final users =
          (data['users'] as List?)
              ?.map(
                (e) => AdminUserModel.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList() ??
          const <AdminUserModel>[];

      return Right(
        AdminUserListEntity(
          users: users,
          total: (data['total'] as num?)?.toInt() ?? users.length,
          page: (data['page'] as num?)?.toInt() ?? page,
          pageSize: (data['pageSize'] as num?)?.toInt() ?? pageSize,
          totalPages: (data['totalPages'] as num?)?.toInt() ?? 1,
        ),
      );
    } on DioException catch (e) {
      return Left(_extractDioErrorMessage(e, 'Không thể tải danh sách user.'));
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }

  @override
  Future<Either<String, void>> banUser(String userId, {String? reason}) async {
    try {
      await _remoteDataSource.banUser(userId, reason: reason);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_extractDioErrorMessage(e, 'Không thể khóa user.'));
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }

  @override
  Future<Either<String, void>> unbanUser(String userId) async {
    try {
      await _remoteDataSource.unbanUser(userId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_extractDioErrorMessage(e, 'Không thể mở khóa user.'));
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }

  @override
  Future<Either<String, void>> changeUserRole(
    String userId,
    String role,
  ) async {
    try {
      await _remoteDataSource.changeUserRole(userId, role);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_extractDioErrorMessage(e, 'Không thể cập nhật role user.'));
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }

  @override
  Future<Either<String, void>> deleteUser(String userId) async {
    try {
      await _remoteDataSource.deleteUser(userId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_extractDioErrorMessage(e, 'Không thể xóa user.'));
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }

  @override
  Future<Either<String, void>> grantPremium(
    String userId, {
    DateTime? expiresAt,
  }) async {
    try {
      await _remoteDataSource.grantPremium(userId, expiresAt: expiresAt);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_extractDioErrorMessage(e, 'Không thể cấp quyền premium.'));
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }

  @override
  Future<Either<String, void>> revokePremium(String userId) async {
    try {
      await _remoteDataSource.revokePremium(userId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(
        _extractDioErrorMessage(e, 'Không thể thu hồi quyền premium.'),
      );
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }

  @override
  Future<Either<String, AdminUserHistoryListEntity>> getUserHistory(
    String userId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final data = await _remoteDataSource.getUserHistory(
        userId,
        page: page,
        pageSize: pageSize,
      );

      final history =
          (data['history'] as List?)
              ?.map(
                (e) => AdminUserHistoryItemModel.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList() ??
          const <AdminUserHistoryItemModel>[];

      return Right(
        AdminUserHistoryListEntity(
          history: history,
          total: (data['total'] as num?)?.toInt() ?? history.length,
          page: (data['page'] as num?)?.toInt() ?? page,
          pageSize: (data['pageSize'] as num?)?.toInt() ?? pageSize,
          totalPages: (data['totalPages'] as num?)?.toInt() ?? 1,
        ),
      );
    } on DioException catch (e) {
      return Left(_extractDioErrorMessage(e, 'Không thể tải lịch sử user.'));
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }

  @override
  Future<Either<String, AdminUserFavoriteListEntity>> getUserFavorites(
    String userId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final data = await _remoteDataSource.getUserFavorites(
        userId,
        page: page,
        pageSize: pageSize,
      );

      final favorites =
          (data['favorites'] as List?)
              ?.map(
                (e) => AdminUserFavoriteItemModel.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList() ??
          const <AdminUserFavoriteItemModel>[];

      return Right(
        AdminUserFavoriteListEntity(
          favorites: favorites,
          total: (data['total'] as num?)?.toInt() ?? favorites.length,
          page: (data['page'] as num?)?.toInt() ?? page,
          pageSize: (data['pageSize'] as num?)?.toInt() ?? pageSize,
          totalPages: (data['totalPages'] as num?)?.toInt() ?? 1,
        ),
      );
    } on DioException catch (e) {
      return Left(
        _extractDioErrorMessage(e, 'Không thể tải danh sách yêu thích user.'),
      );
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }

  @override
  Future<Either<String, AdminUserPlaylistListEntity>> getUserPlaylists(
    String userId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final data = await _remoteDataSource.getUserPlaylists(
        userId,
        page: page,
        pageSize: pageSize,
      );

      final playlists =
          (data['playlists'] as List?)
              ?.map(
                (e) => AdminUserPlaylistItemModel.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList() ??
          const <AdminUserPlaylistItemModel>[];

      return Right(
        AdminUserPlaylistListEntity(
          playlists: playlists,
          total: (data['total'] as num?)?.toInt() ?? playlists.length,
          page: (data['page'] as num?)?.toInt() ?? page,
          pageSize: (data['pageSize'] as num?)?.toInt() ?? pageSize,
          totalPages: (data['totalPages'] as num?)?.toInt() ?? 1,
        ),
      );
    } on DioException catch (e) {
      return Left(_extractDioErrorMessage(e, 'Không thể tải playlists user.'));
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }

  // ─── Dashboard ─────────────────────────────────────────────────────────────

  @override
  Future<Either<String, AdminDashboardSummaryEntity>> getDashboardSummary() async {
    try {
      final data = await _remoteDataSource.getDashboardSummary();
      return Right(AdminDashboardSummaryEntity(
        totalUsers: (data['totalUsers'] as num?)?.toInt() ?? 0,
        totalPlayCount: (data['totalPlayCount'] as num?)?.toInt() ?? 0,
        newUsersToday: (data['newUsersToday'] as num?)?.toInt() ?? 0,
        cachedTracks: (data['cachedTracks'] as num?)?.toInt() ?? 0,
      ));
    } on DioException catch (e) {
      return Left(_extractDioErrorMessage(e, 'Không thể tải dashboard summary.'));
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }

  @override
  Future<Either<String, AdminDashboardChartEntity>> getDashboardUserGrowth({String? month}) async {
    try {
      final data = await _remoteDataSource.getDashboardUserGrowth(month: month);
      final rawPoints = data['points'] as List<dynamic>? ?? [];
      final points = rawPoints.map((p) {
        final m = Map<String, dynamic>.from(p as Map);
        return AdminDashboardDailyPointEntity(
          date: m['date'] as String? ?? '',
          value: (m['value'] as num?)?.toInt() ?? 0,
        );
      }).toList();
      return Right(AdminDashboardChartEntity(month: data['month'] as String?, points: points));
    } on DioException catch (e) {
      return Left(_extractDioErrorMessage(e, 'Không thể tải user growth.'));
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }

  @override
  Future<Either<String, AdminDashboardChartEntity>> getDashboardPlayTrend({String? month}) async {
    try {
      final data = await _remoteDataSource.getDashboardPlayTrend(month: month);
      final rawPoints = data['points'] as List<dynamic>? ?? [];
      final points = rawPoints.map((p) {
        final m = Map<String, dynamic>.from(p as Map);
        return AdminDashboardDailyPointEntity(
          date: m['date'] as String? ?? '',
          value: (m['value'] as num?)?.toInt() ?? 0,
        );
      }).toList();
      return Right(AdminDashboardChartEntity(month: data['month'] as String?, points: points));
    } on DioException catch (e) {
      return Left(_extractDioErrorMessage(e, 'Không thể tải play trend.'));
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }

  @override
  Future<Either<String, AdminDashboardTopTracksEntity>> getDashboardTopTracks({
    String? month,
    int limit = 10,
  }) async {
    try {
      final data = await _remoteDataSource.getDashboardTopTracks(month: month, limit: limit);
      final rawItems = data['items'] as List<dynamic>? ?? [];
      final items = rawItems.map((item) {
        final m = Map<String, dynamic>.from(item as Map);
        return AdminDashboardTopTrackEntity(
          trackExternalId: m['trackExternalId'] as String? ?? '',
          title: m['title'] as String?,
          artistName: m['artistName'] as String?,
          artworkUrl: m['artworkUrl'] as String?,
          playCount: (m['playCount'] as num?)?.toInt() ?? 0,
        );
      }).toList();
      return Right(AdminDashboardTopTracksEntity(month: data['month'] as String?, items: items));
    } on DioException catch (e) {
      return Left(_extractDioErrorMessage(e, 'Không thể tải top tracks.'));
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }

  // ─── Analytics ─────────────────────────────────────────────────────────────

  @override
  Future<Either<String, AdminAnalyticsOverviewEntity>> getAnalyticsOverview() async {
    try {
      final data = await _remoteDataSource.getAnalyticsOverview();
      return Right(AdminAnalyticsOverviewEntity(
        totalUsers: (data['totalUsers'] as num?)?.toInt() ?? 0,
        totalBannedUsers: (data['totalBannedUsers'] as num?)?.toInt() ?? 0,
        totalAdmins: (data['totalAdmins'] as num?)?.toInt() ?? 0,
        newUsersLast7Days: (data['newUsersLast7Days'] as num?)?.toInt() ?? 0,
        totalListeningTimeSeconds:
            (data['totalListeningTimeSeconds'] as num?)?.toInt() ?? 0,
        totalTracks: (data['totalTracks'] as num?)?.toInt() ?? 0,
        totalPlaylists: (data['totalPlaylists'] as num?)?.toInt() ?? 0,
      ));
    } on DioException catch (e) {
      return Left(_extractDioErrorMessage(e, 'Không thể tải analytics overview.'));
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }

  @override
  Future<Either<String, List<AdminAnalyticsTopTrackEntity>>> getAnalyticsTopTracks({int count = 10}) async {
    try {
      final rawList = await _remoteDataSource.getAnalyticsTopTracks(count: count);
      final tracks = rawList.map((item) {
        final m = Map<String, dynamic>.from(item as Map);
        return AdminAnalyticsTopTrackEntity(
          trackId: m['trackId'] as String? ?? '',
          title: m['title'] as String? ?? '',
          artist: m['artist'] as String? ?? '',
          playCount: (m['playCount'] as num?)?.toInt() ?? 0,
        );
      }).toList();
      return Right(tracks);
    } on DioException catch (e) {
      return Left(_extractDioErrorMessage(e, 'Không thể tải top tracks analytics.'));
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }

  @override
  Future<Either<String, List<AdminAnalyticsDailyStatEntity>>> getAnalyticsDailyStats({
    String? from,
    String? to,
  }) async {
    try {
      final rawList = await _remoteDataSource.getAnalyticsDailyStats(from: from, to: to);
      final stats = rawList.map((item) {
        final m = Map<String, dynamic>.from(item as Map);
        return AdminAnalyticsDailyStatEntity(
          date: m['date'] as String? ?? '',
          newUsers: (m['newUsers'] as num?)?.toInt() ?? 0,
          totalListens: (m['totalListens'] as num?)?.toInt() ?? 0,
          totalListeningTimeSeconds:
              (m['totalListeningTimeSeconds'] as num?)?.toInt() ?? 0,
        );
      }).toList();
      return Right(stats);
    } on DioException catch (e) {
      return Left(_extractDioErrorMessage(e, 'Không thể tải daily stats.'));
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }

  @override
  Future<Either<String, AdminSubscriptionStatsEntity>> getSubscriptionStats() async {
    try {
      final data = await _remoteDataSource.getSubscriptionStats();
      return Right(AdminSubscriptionStatsEntity(
        totalPremiumUsers: (data['totalPremiumUsers'] as num?)?.toInt() ?? 0,
        totalFreeUsers: (data['totalFreeUsers'] as num?)?.toInt() ?? 0,
        activeSubscriptions: (data['activeSubscriptions'] as num?)?.toInt() ?? 0,
        totalRevenue: (data['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      ));
    } on DioException catch (e) {
      return Left(_extractDioErrorMessage(e, 'Không thể tải subscription stats.'));
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }
}
