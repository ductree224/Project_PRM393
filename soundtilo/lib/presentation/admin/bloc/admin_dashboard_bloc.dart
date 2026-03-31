import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soundtilo/domain/usecases/admin_dashboard_usecases.dart';
import 'package:soundtilo/presentation/admin/bloc/admin_dashboard_event.dart';
import 'package:soundtilo/presentation/admin/bloc/admin_dashboard_state.dart';

class AdminDashboardBloc
    extends Bloc<AdminDashboardEvent, AdminDashboardState> {
  final GetDashboardSummaryUseCase _getSummary;
  final GetDashboardPlayTrendUseCase _getPlayTrend;
  final GetDashboardUserGrowthUseCase _getUserGrowth;
  final GetDashboardTopTracksUseCase _getTopTracks;

  AdminDashboardBloc({
    required GetDashboardSummaryUseCase getSummary,
    required GetDashboardPlayTrendUseCase getPlayTrend,
    required GetDashboardUserGrowthUseCase getUserGrowth,
    required GetDashboardTopTracksUseCase getTopTracks,
  }) : _getSummary = getSummary,
       _getPlayTrend = getPlayTrend,
       _getUserGrowth = getUserGrowth,
       _getTopTracks = getTopTracks,
       super(const AdminDashboardState()) {
    on<AdminDashboardStarted>(_onStarted);
    on<AdminDashboardRefresh>(_onRefresh);
    on<AdminDashboardMonthChanged>(_onMonthChanged);
  }

  Future<void> _onStarted(
    AdminDashboardStarted event,
    Emitter<AdminDashboardState> emit,
  ) async {
    await _load(emit, month: event.month);
  }

  Future<void> _onRefresh(
    AdminDashboardRefresh event,
    Emitter<AdminDashboardState> emit,
  ) async {
    await _load(emit, month: state.selectedMonth);
  }

  Future<void> _onMonthChanged(
    AdminDashboardMonthChanged event,
    Emitter<AdminDashboardState> emit,
  ) async {
    emit(state.copyWith(selectedMonth: event.month, clearError: true));
    await _loadCharts(emit, month: event.month);
  }

  Future<void> _load(
    Emitter<AdminDashboardState> emit, {
    String? month,
  }) async {
    emit(state.copyWith(
      status: AdminDashboardStatus.loading,
      selectedMonth: month,
      clearError: true,
    ));

    final summaryResult = await _getSummary();
    final playTrendResult = await _getPlayTrend(month: month);
    final userGrowthResult = await _getUserGrowth(month: month);
    final topTracksResult = await _getTopTracks(month: month, limit: 10);

    final String? error = summaryResult.fold((e) => e, (_) => null);

    emit(state.copyWith(
      status: error != null
          ? AdminDashboardStatus.error
          : AdminDashboardStatus.success,
      summary: summaryResult.fold((_) => null, (v) => v),
      playTrend: playTrendResult.fold((_) => null, (v) => v),
      userGrowth: userGrowthResult.fold((_) => null, (v) => v),
      topTracks: topTracksResult.fold((_) => null, (v) => v),
      errorMessage: error,
    ));
  }

  Future<void> _loadCharts(
    Emitter<AdminDashboardState> emit, {
    String? month,
  }) async {
    final playTrendResult = await _getPlayTrend(month: month);
    final userGrowthResult = await _getUserGrowth(month: month);
    final topTracksResult = await _getTopTracks(month: month, limit: 10);

    emit(state.copyWith(
      playTrend: playTrendResult.fold((_) => null, (v) => v),
      userGrowth: userGrowthResult.fold((_) => null, (v) => v),
      topTracks: topTracksResult.fold((_) => null, (v) => v),
    ));
  }
}
