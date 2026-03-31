import 'package:dartz/dartz.dart';
import 'package:soundtilo/domain/entities/admin_analytics_entity.dart';
import 'package:soundtilo/domain/repository/admin_repository.dart';

class GetAnalyticsOverviewUseCase {
  final AdminRepository repository;

  GetAnalyticsOverviewUseCase(this.repository);

  Future<Either<String, AdminAnalyticsOverviewEntity>> call() =>
      repository.getAnalyticsOverview();
}

class GetAnalyticsTopTracksUseCase {
  final AdminRepository repository;

  GetAnalyticsTopTracksUseCase(this.repository);

  Future<Either<String, List<AdminAnalyticsTopTrackEntity>>> call({
    int count = 10,
  }) =>
      repository.getAnalyticsTopTracks(count: count);
}

class GetAnalyticsDailyStatsUseCase {
  final AdminRepository repository;

  GetAnalyticsDailyStatsUseCase(this.repository);

  Future<Either<String, List<AdminAnalyticsDailyStatEntity>>> call({
    String? from,
    String? to,
  }) =>
      repository.getAnalyticsDailyStats(from: from, to: to);
}

class GetAdminSubscriptionStatsUseCase {
  final AdminRepository repository;

  GetAdminSubscriptionStatsUseCase(this.repository);

  Future<Either<String, AdminSubscriptionStatsEntity>> call() =>
      repository.getSubscriptionStats();
}
