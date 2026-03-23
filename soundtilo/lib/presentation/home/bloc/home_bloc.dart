import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soundtilo/core/debug/perf_trace.dart';
import 'package:soundtilo/domain/entities/track_entity.dart';
import 'package:soundtilo/domain/usecases/track_usecases.dart';
import 'package:soundtilo/presentation/home/bloc/home_event.dart';
import 'package:soundtilo/presentation/home/bloc/home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  static const int _pageSize = 20;
  final GetTrendingUseCase _getTrendingUseCase;

  HomeBloc({required GetTrendingUseCase getTrendingUseCase})
      : _getTrendingUseCase = getTrendingUseCase,
        super(HomeInitial()) {
    on<HomeLoadTrending>(_onLoadTrending, transformer: droppable());
    on<HomeRefresh>(_onRefresh, transformer: droppable());
    on<HomeLoadMore>(_onLoadMore, transformer: droppable());
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

    final result = await _getTrendingUseCase(limit: _pageSize, offset: 0);
    result.fold(
      (error) => emit(HomeError(error)),
      (tracks) => emit(HomeLoaded(
        trendingTracks: tracks,
        currentOffset: tracks.length,
        hasMore: tracks.length >= _pageSize,
      )),
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
      final loaded = state as HomeLoaded;
      previousTracks = loaded.trendingTracks;
      emit(HomeRefreshing(
        trendingTracks: loaded.trendingTracks,
        currentOffset: loaded.currentOffset,
        hasMore: loaded.hasMore,
      ));
    } else if (state is HomeRefreshing) {
      previousTracks = (state as HomeRefreshing).trendingTracks;
    } else if (state is! HomeLoading) {
      emit(HomeLoading());
    }

    final result = await _getTrendingUseCase(limit: _pageSize, offset: 0);
    result.fold(
      (error) {
        if (previousTracks != null) {
          emit(HomeLoaded(
            trendingTracks: List.unmodifiable(previousTracks),
            currentOffset: previousTracks.length,
            hasMore: previousTracks.length >= _pageSize,
          ));
          return;
        }
        emit(HomeError(error));
      },
      (tracks) => emit(HomeLoaded(
        trendingTracks: tracks,
        currentOffset: tracks.length,
        hasMore: tracks.length >= _pageSize,
      )),
    );

    stopwatch.stop();
    PerfTrace.slow(
      'home.refresh',
      stopwatch,
      thresholdMs: 180,
    );
  }

  Future<void> _onLoadMore(
      HomeLoadMore event, Emitter<HomeState> emit) async {
    final current = state;
    if (current is! HomeLoaded || !current.hasMore || current.isLoadingMore) {
      return;
    }

    final stopwatch = Stopwatch()..start();
    emit(current.copyWith(isLoadingMore: true));

    final result = await _getTrendingUseCase(
      limit: _pageSize,
      offset: current.currentOffset,
    );

    result.fold(
      (error) {
        PerfTrace.log('home.loadMore.error', error);
        emit(current.copyWith(isLoadingMore: false));
      },
      (newTracks) {
        final merged = [...current.trendingTracks, ...newTracks];
        emit(HomeLoaded(
          trendingTracks: merged,
          currentOffset: merged.length,
          hasMore: newTracks.length >= _pageSize,
          isLoadingMore: false,
        ));
      },
    );

    stopwatch.stop();
    PerfTrace.slow(
      'home.loadMore',
      stopwatch,
      thresholdMs: 180,
      values: <String, Object?>{
        'offset': current.currentOffset,
        'pageSize': _pageSize,
      },
    );
  }
}
