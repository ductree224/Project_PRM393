import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soundtilo/domain/usecases/admin_analytics_usecases.dart';
import 'admin_analytics_event.dart';
import 'admin_analytics_state.dart';

class AdminAnalyticsBloc extends Bloc<AdminAnalyticsEvent, AdminAnalyticsState> {
  final GetAnalyticsOverviewUseCase getOverview;
  final GetAnalyticsTopTracksUseCase getTopTracks;
  final GetAnalyticsDailyStatsUseCase getDailyStats;
  final GetAdminSubscriptionStatsUseCase getSubscriptionStats;

  AdminAnalyticsBloc({
    required this.getOverview,
    required this.getTopTracks,
    required this.getDailyStats,
    required this.getSubscriptionStats,
  }) : super(AdminAnalyticsState.initial()) {
    on<AdminAnalyticsStarted>(_onStarted);
    on<AdminAnalyticsRefresh>(_onRefresh);
    on<AdminAnalyticsDateRangeChanged>(_onDateRangeChanged);
  }

  Future<void> _onStarted(AdminAnalyticsStarted event, Emitter<AdminAnalyticsState> emit) async {
    await _loadAll(emit);
  }

  Future<void> _onRefresh(AdminAnalyticsRefresh event, Emitter<AdminAnalyticsState> emit) async {
    await _loadAll(emit);
  }

  Future<void> _onDateRangeChanged(AdminAnalyticsDateRangeChanged event, Emitter<AdminAnalyticsState> emit) async {
    emit(state.copyWith(fromDate: event.from, toDate: event.to, clearError: true));
    await _loadDailyStats(emit);
  }

  Future<void> _loadAll(Emitter<AdminAnalyticsState> emit) async {
    emit(state.copyWith(status: AdminAnalyticsStatus.loading, clearError: true));

    final overviewResult = await getOverview();
    final topTracksResult = await getTopTracks(count: 10);
    final dailyResult = await getDailyStats(from: state.fromDate, to: state.toDate);
    final subStatsResult = await getSubscriptionStats();

    String? error;
    overviewResult.fold((e) => error = e, (_) {});
    if (error != null) {
      emit(state.copyWith(status: AdminAnalyticsStatus.error, errorMessage: error));
      return;
    }

    emit(state.copyWith(
      status: AdminAnalyticsStatus.success,
      overview: overviewResult.getOrElse(() => throw Exception()),
      topTracks: topTracksResult.getOrElse(() => []),
      dailyStats: dailyResult.getOrElse(() => []),
      subscriptionStats: subStatsResult.fold((_) => null, (stats) => stats),
    ));
  }

  Future<void> _loadDailyStats(Emitter<AdminAnalyticsState> emit) async {
    emit(state.copyWith(status: AdminAnalyticsStatus.loading, clearError: true));
    final result = await getDailyStats(from: state.fromDate, to: state.toDate);
    result.fold(
      (error) => emit(state.copyWith(status: AdminAnalyticsStatus.error, errorMessage: error)),
      (data) => emit(state.copyWith(status: AdminAnalyticsStatus.success, dailyStats: data)),
    );
  }
}
