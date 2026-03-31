import 'package:dartz/dartz.dart';
import 'package:soundtilo/domain/entities/admin_dashboard_entity.dart';
import 'package:soundtilo/domain/repository/admin_repository.dart';

class GetDashboardSummaryUseCase {
  final AdminRepository repository;

  GetDashboardSummaryUseCase(this.repository);

  Future<Either<String, AdminDashboardSummaryEntity>> call() =>
      repository.getDashboardSummary();
}

class GetDashboardUserGrowthUseCase {
  final AdminRepository repository;

  GetDashboardUserGrowthUseCase(this.repository);

  Future<Either<String, AdminDashboardChartEntity>> call({String? month}) =>
      repository.getDashboardUserGrowth(month: month);
}

class GetDashboardPlayTrendUseCase {
  final AdminRepository repository;

  GetDashboardPlayTrendUseCase(this.repository);

  Future<Either<String, AdminDashboardChartEntity>> call({String? month}) =>
      repository.getDashboardPlayTrend(month: month);
}

class GetDashboardTopTracksUseCase {
  final AdminRepository repository;

  GetDashboardTopTracksUseCase(this.repository);

  Future<Either<String, AdminDashboardTopTracksEntity>> call({
    String? month,
    int limit = 10,
  }) =>
      repository.getDashboardTopTracks(month: month, limit: limit);
}
