import 'package:equatable/equatable.dart';
import 'package:soundtilo/domain/entities/admin_analytics_entity.dart';

enum AdminAnalyticsStatus { initial, loading, success, error }

class AdminAnalyticsState extends Equatable {
  final AdminAnalyticsStatus status;
  final AdminAnalyticsOverviewEntity? overview;
  final List<AdminAnalyticsTopTrackEntity> topTracks;
  final List<AdminAnalyticsDailyStatEntity> dailyStats;
  final AdminSubscriptionStatsEntity? subscriptionStats;
  final String fromDate;
  final String toDate;
  final String? errorMessage;

  const AdminAnalyticsState({
    this.status = AdminAnalyticsStatus.initial,
    this.overview,
    this.topTracks = const [],
    this.dailyStats = const [],
    this.subscriptionStats,
    required this.fromDate,
    required this.toDate,
    this.errorMessage,
  });

  factory AdminAnalyticsState.initial() {
    final now = DateTime.now();
    final to = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final from30 = now.subtract(const Duration(days: 29));
    final from = '${from30.year}-${from30.month.toString().padLeft(2, '0')}-${from30.day.toString().padLeft(2, '0')}';
    return AdminAnalyticsState(fromDate: from, toDate: to);
  }

  AdminAnalyticsState copyWith({
    AdminAnalyticsStatus? status,
    AdminAnalyticsOverviewEntity? overview,
    List<AdminAnalyticsTopTrackEntity>? topTracks,
    List<AdminAnalyticsDailyStatEntity>? dailyStats,
    AdminSubscriptionStatsEntity? subscriptionStats,
    String? fromDate,
    String? toDate,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AdminAnalyticsState(
      status: status ?? this.status,
      overview: overview ?? this.overview,
      topTracks: topTracks ?? this.topTracks,
      dailyStats: dailyStats ?? this.dailyStats,
      subscriptionStats: subscriptionStats ?? this.subscriptionStats,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, overview, topTracks, dailyStats, subscriptionStats, fromDate, toDate, errorMessage];
}
