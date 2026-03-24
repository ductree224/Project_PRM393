import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soundtilo/core/debug/perf_trace.dart';
import 'package:soundtilo/data/models/album_model.dart';
import 'package:soundtilo/domain/entities/track_entity.dart';
import 'package:soundtilo/domain/repositories/album_repository.dart';
import 'package:soundtilo/domain/usecases/track_usecases.dart';
import 'package:soundtilo/presentation/home/bloc/home_event.dart';
import 'package:soundtilo/presentation/home/bloc/home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  static const int _homeTrendingLimit = 18;
  final GetTrendingUseCase _getTrendingUseCase;
  final AlbumRepository _albumRepository;

  HomeBloc({
    required GetTrendingUseCase getTrendingUseCase,
    required AlbumRepository albumRepository,
  })  : _getTrendingUseCase = getTrendingUseCase,
        _albumRepository = albumRepository,
        super(HomeInitial()) {
    on<HomeLoadTrending>(_onLoadTrending, transformer: droppable());
    on<HomeRefresh>(_onRefresh, transformer: droppable());
  }

  Future<List<AlbumModel>> _fetchAdminAlbums() async {
    final result = await _albumRepository.getAlbums();
    return result.fold(
      (_) => <AlbumModel>[],
      (albums) => albums,
    );
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

    // Fetch trending tracks and admin albums in parallel
    final results = await Future.wait([
      _getTrendingUseCase(limit: _homeTrendingLimit),
      _fetchAdminAlbums(),
    ]);

    final trackResult = results[0] as dynamic;
    final adminAlbums = results[1] as List<AlbumModel>;

    trackResult.fold(
      (error) => emit(HomeError(error)),
      (tracks) => emit(HomeLoaded(
        trendingTracks: tracks as List<TrackEntity>,
        adminAlbums: adminAlbums,
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
    List<AlbumModel> previousAlbums = const [];

    if (state is HomeLoaded) {
      previousTracks = (state as HomeLoaded).trendingTracks;
      previousAlbums = (state as HomeLoaded).adminAlbums;
      emit(HomeRefreshing(
        trendingTracks: previousTracks,
        adminAlbums: previousAlbums,
      ));
    } else if (state is HomeRefreshing) {
      previousTracks = (state as HomeRefreshing).trendingTracks;
      previousAlbums = (state as HomeRefreshing).adminAlbums;
    } else if (state is! HomeLoading) {
      emit(HomeLoading());
    }

    // Fetch trending tracks and admin albums in parallel
    final results = await Future.wait([
      _getTrendingUseCase(limit: _homeTrendingLimit),
      _fetchAdminAlbums(),
    ]);

    final trackResult = results[0] as dynamic;
    final adminAlbums = results[1] as List<AlbumModel>;

    trackResult.fold(
      (error) {
        if (previousTracks != null) {
          emit(HomeLoaded(
            trendingTracks: List.unmodifiable(previousTracks),
            adminAlbums: previousAlbums,
          ));
          return;
        }
        emit(HomeError(error));
      },
      (tracks) => emit(HomeLoaded(
        trendingTracks: tracks as List<TrackEntity>,
        adminAlbums: adminAlbums,
      )),
    );

    stopwatch.stop();
    PerfTrace.slow(
      'home.refresh',
      stopwatch,
      thresholdMs: 180,
    );
  }
}
