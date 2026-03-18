import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soundtilo/core/debug/perf_trace.dart';
import 'package:soundtilo/domain/entities/track_entity.dart';
import 'package:soundtilo/domain/usecases/track_usecases.dart';
import 'package:soundtilo/presentation/home/bloc/home_event.dart';
import 'package:soundtilo/presentation/home/bloc/home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  static const int _homeTrendingLimit = 18;
  final GetTrendingUseCase _getTrendingUseCase;

  HomeBloc({required GetTrendingUseCase getTrendingUseCase})
      : _getTrendingUseCase = getTrendingUseCase,
        super(HomeInitial()) {
    on<HomeLoadTrending>(_onLoadTrending, transformer: droppable());
    on<HomeRefresh>(_onRefresh, transformer: droppable());
  }

  Future<void> _onLoadTrending(
      HomeLoadTrending event, Emitter<HomeState> emit) async {
    if (state is HomeLoaded || state is HomeRefreshing || state is HomeLoading) {
      PerfTrace.log(
        'home.loadTrending.skip',
        'skip duplicate initial load while state already has content/loading',
      );
      return;
    }

    final stopwatch = Stopwatch()..start();
    if (state is HomeInitial || state is HomeError) {
      emit(HomeLoading());
    }

    final result = await _getTrendingUseCase(limit: _homeTrendingLimit);
    result.fold(
      (error) => emit(HomeError(error)),
      (tracks) => emit(HomeLoaded(trendingTracks: tracks)),
    );

    stopwatch.stop();
    PerfTrace.slow(
      'home.loadTrending',
      stopwatch,
      thresholdMs: 180,
    );
  }

  Future<void> _onRefresh(HomeRefresh event, Emitter<HomeState> emit) async {
    final stopwatch = Stopwatch()..start();
    List<TrackEntity>? previousTracks;
    if (state is HomeLoaded) {
      previousTracks = (state as HomeLoaded).trendingTracks;
      emit(HomeRefreshing(trendingTracks: (state as HomeLoaded).trendingTracks));
    } else if (state is HomeRefreshing) {
      previousTracks = (state as HomeRefreshing).trendingTracks;
    } else if (state is! HomeLoading) {
      emit(HomeLoading());
    }

    final result = await _getTrendingUseCase(limit: _homeTrendingLimit);
    result.fold(
      (error) {
        if (previousTracks != null) {
          emit(HomeLoaded(trendingTracks: List.unmodifiable(previousTracks)));
          return;
        }
        emit(HomeError(error));
      },
      (tracks) => emit(HomeLoaded(trendingTracks: tracks)),
    );

    stopwatch.stop();
    PerfTrace.slow(
      'home.refresh',
      stopwatch,
      thresholdMs: 180,
    );
  }
}
