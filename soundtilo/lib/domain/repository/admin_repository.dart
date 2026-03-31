import 'package:dartz/dartz.dart';
import 'package:soundtilo/domain/entities/admin_analytics_entity.dart';
import 'package:soundtilo/domain/entities/admin_dashboard_entity.dart';
import 'package:soundtilo/domain/entities/admin_user_entity.dart';

abstract class AdminRepository {
  Future<Either<String, AdminUserListEntity>> getUsers({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? role,
    bool? isBanned,
    String? subscriptionTier,
  });

  Future<Either<String, void>> banUser(String userId, {String? reason});

  Future<Either<String, void>> unbanUser(String userId);

  Future<Either<String, void>> changeUserRole(String userId, String role);

  Future<Either<String, void>> deleteUser(String userId);

  Future<Either<String, void>> grantPremium(
    String userId, {
    DateTime? expiresAt,
  });

  Future<Either<String, void>> revokePremium(String userId);

  Future<Either<String, AdminUserHistoryListEntity>> getUserHistory(
    String userId, {
    int page = 1,
    int pageSize = 20,
  });

  Future<Either<String, AdminUserFavoriteListEntity>> getUserFavorites(
    String userId, {
    int page = 1,
    int pageSize = 20,
  });

  Future<Either<String, AdminUserPlaylistListEntity>> getUserPlaylists(
    String userId, {
    int page = 1,
    int pageSize = 20,
  });

  // ─── Dashboard ─────────────────────────────────────────────────────────────

  Future<Either<String, AdminDashboardSummaryEntity>> getDashboardSummary();

  Future<Either<String, AdminDashboardChartEntity>> getDashboardUserGrowth({
    String? month,
  });

  Future<Either<String, AdminDashboardChartEntity>> getDashboardPlayTrend({
    String? month,
  });

  Future<Either<String, AdminDashboardTopTracksEntity>> getDashboardTopTracks({
    String? month,
    int limit = 10,
  });

  // ─── Analytics ─────────────────────────────────────────────────────────────

  Future<Either<String, AdminAnalyticsOverviewEntity>> getAnalyticsOverview();

  Future<Either<String, List<AdminAnalyticsTopTrackEntity>>>
  getAnalyticsTopTracks({int count = 10});

  Future<Either<String, List<AdminAnalyticsDailyStatEntity>>>
  getAnalyticsDailyStats({String? from, String? to});

  Future<Either<String, AdminSubscriptionStatsEntity>> getSubscriptionStats();
}
