import 'package:dartz/dartz.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soundtilo/data/models/album_model.dart';
import 'package:soundtilo/domain/entities/track_entity.dart';
import 'package:soundtilo/domain/repositories/album_repository.dart';
import 'package:soundtilo/domain/usecases/history_usecases.dart';
import 'package:soundtilo/domain/usecases/track_usecases.dart';
import 'package:soundtilo/presentation/home/bloc/home_event.dart';
import 'package:soundtilo/presentation/home/bloc/home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  static const int _pageSize = 20;
  final GetTrendingUseCase _getTrendingUseCase;
  final GetHistoryUseCase _getHistoryUseCase;
  final GetTrackUseCase _getTrackUseCase;
  final AlbumRepository _albumRepository;

  HomeBloc({
    required GetTrendingUseCase getTrendingUseCase,
    required GetHistoryUseCase getHistoryUseCase,
    required GetTrackUseCase getTrackUseCase,
    required AlbumRepository albumRepository,
  })  : _getTrendingUseCase = getTrendingUseCase,
        _getHistoryUseCase = getHistoryUseCase,
        _getTrackUseCase = getTrackUseCase,
        _albumRepository = albumRepository,
        super(HomeInitial()) {
    on<HomeLoadTrending>(_onLoadTrending, transformer: droppable());
    on<HomeRefresh>(_onRefresh, transformer: droppable());
    on<HomeLoadMore>(_onLoadMore, transformer: droppable());
    on<HomeLoadByTag>(_onLoadByTag, transformer: restartable());
  }
  Future<List<AlbumModel>> _fetchAdminAlbums() async {
    final result = await _albumRepository.getAlbums();
    return result.fold(
      (_) => <AlbumModel>[],
      (albums) => albums,
    );
  }

  Future<List<TrackEntity>> _fetchRecentTracks() async {
    final historyResult = await _getHistoryUseCase(pageSize: 8);
    return historyResult.fold(
      (_) => <TrackEntity>[],
      (history) async {
        if (history.isEmpty) return <TrackEntity>[];
        
        // Take unique track external IDs
        final uniqueIds = history
            .map((h) => h['trackExternalId']?.toString() ?? '')
            .where((id) => id.isNotEmpty)
            .toSet()
            .take(6)
            .toList();

        final trackFutures = uniqueIds.map((id) => _getTrackUseCase(id));
        final trackResults = await Future.wait(trackFutures);
        
        return trackResults
            .map((r) => r.fold((_) => null, (t) => t))
            .whereType<TrackEntity>()
            .toList();
      },
    );
  }

  Future<void> _onLoadTrending(
      HomeLoadTrending event, Emitter<HomeState> emit) async {
    if (state is HomeLoaded || state is HomeRefreshing || state is HomeLoading) return;

    emit(HomeLoading());

    // Fetch trending tracks, tag tracks, admin albums, and recent tracks in parallel
    final results = await Future.wait([
      _getTrendingUseCase(limit: _pageSize, offset: 0),
      _getTrendingUseCase(genre: 'pop', limit: 12, offset: 0),
      _fetchAdminAlbums(),
      _fetchRecentTracks(),
    ]);

    final trendingResult = results[0] as Either<String, List<TrackEntity>>;
    final tagResult = results[1] as Either<String, List<TrackEntity>>;
    final adminAlbums = results[2] as List<AlbumModel>;
    final recentTracks = results[3] as List<TrackEntity>;

    if (emit.isDone) return;

    if (trendingResult.isLeft()) {
      emit(HomeError(trendingResult.fold((e) => e, (_) => 'Lỗi không xác định')));
      return;
    }

    final trendingTracks = trendingResult.getOrElse(() => []);
    final tagTracks = tagResult.getOrElse(() => []);

    emit(HomeLoaded(
      trendingTracks: trendingTracks,
      tagTracks: tagTracks,
      recentTracks: recentTracks,
      selectedTag: 'pop',
      adminAlbums: adminAlbums,
      currentOffset: trendingTracks.length,
      hasMore: trendingTracks.length >= _pageSize,
    ));
  }

  Future<void> _onLoadByTag(HomeLoadByTag event, Emitter<HomeState> emit) async {
    if (state is! HomeLoaded) return;
    
    // Cập nhật tag ngay lập tức để UI sáng lên đúng chỗ
    final currentState = state as HomeLoaded;
    emit(currentState.copyWith(isTagLoading: true, selectedTag: event.tag));

    final result = await _getTrendingUseCase(genre: event.tag, limit: 12, offset: 0);

    result.fold(
      (error) {
        if (state is HomeLoaded) {
          emit((state as HomeLoaded).copyWith(isTagLoading: false));
        }
      },
      (tracks) {
        if (state is HomeLoaded) {
          // QUAN TRỌNG: Phải lấy state hiện tại (đã có selectedTag mới) để copyWith
          emit((state as HomeLoaded).copyWith(
            tagTracks: tracks,
            isTagLoading: false,
            // Đảm bảo không truyền selectedTag vào đây để nó giữ nguyên giá trị đã update ở trên
          ));
        }
      },
    );
  }

  Future<void> _onRefresh(HomeRefresh event, Emitter<HomeState> emit) async {
    if (state is HomeLoaded) {
      final current = state as HomeLoaded;
      emit(HomeRefreshing(
        trendingTracks: current.trendingTracks,
        recentTracks: current.recentTracks,
        adminAlbums: current.adminAlbums,
        currentOffset: current.currentOffset,
        hasMore: current.hasMore,
      ));
    } else if (state is! HomeRefreshing && state is! HomeLoading) {
      emit(HomeLoading());
    }

    // Fetch trending tracks, admin albums, and recent tracks in parallel
    final results = await Future.wait([
      _getTrendingUseCase(limit: _pageSize, offset: 0),
      _fetchAdminAlbums(),
      _fetchRecentTracks(),
    ]);

    final trendingResult = results[0] as Either<String, List<TrackEntity>>;
    final adminAlbums = results[1] as List<AlbumModel>;
    final recentTracks = results[2] as List<TrackEntity>;

    trendingResult.fold(
      (error) {
        final current = state;
        if (current is HomeRefreshing) {
          emit(HomeLoaded(
            trendingTracks: current.trendingTracks,
            adminAlbums: current.adminAlbums,
            currentOffset: current.currentOffset,
            hasMore: current.hasMore,
          ));
        } else {
          emit(HomeError(error));
        }
      },
      (tracks) {
        emit(HomeLoaded(
          trendingTracks: tracks,
          adminAlbums: adminAlbums,
          recentTracks: recentTracks,
          currentOffset: tracks.length,
          hasMore: tracks.length >= _pageSize,
        ));
      },
    );
  }

  Future<void> _onLoadMore(HomeLoadMore event, Emitter<HomeState> emit) async {
    final current = state;
    if (current is! HomeLoaded || !current.hasMore || current.isLoadingMore) return;

    emit(current.copyWith(isLoadingMore: true));

    final result = await _getTrendingUseCase(
      limit: _pageSize,
      offset: current.currentOffset,
    );

    result.fold(
      (error) => emit(current.copyWith(isLoadingMore: false)),
      (newTracks) {
        final merged = [...current.trendingTracks, ...newTracks];
        emit(current.copyWith(
          trendingTracks: merged,
          currentOffset: merged.length,
          hasMore: newTracks.length >= _pageSize,
          isLoadingMore: false,
        ));
      },
    );
  }
}
