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
    on<HomeLoadByTag>(_onLoadByTag, transformer: restartable());
  }

  Future<void> _onLoadTrending(
      HomeLoadTrending event, Emitter<HomeState> emit) async {
    if (state is HomeLoaded || state is HomeRefreshing || state is HomeLoading) return;

    emit(HomeLoading());

    final trendingResult = await _getTrendingUseCase(limit: _pageSize, offset: 0);
    final tagResult = await _getTrendingUseCase(genre: 'pop', limit: 10, offset: 0);

    trendingResult.fold(
      (error) => emit(HomeError(error)),
      (trendingTracks) {
        tagResult.fold(
          (error) => emit(HomeLoaded(trendingTracks: trendingTracks, currentOffset: trendingTracks.length)),
          (tagTracks) => emit(HomeLoaded(
            trendingTracks: trendingTracks,
            tagTracks: tagTracks,
            selectedTag: 'pop',
            currentOffset: trendingTracks.length,
            hasMore: trendingTracks.length >= _pageSize,
          )),
        );
      },
    );
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
    final current = state;
    if (current is HomeLoaded) {
      emit(HomeRefreshing(
        trendingTracks: current.trendingTracks,
        currentOffset: current.currentOffset,
        hasMore: current.hasMore,
      ));
    } else if (current is! HomeRefreshing && current is! HomeLoading) {
      emit(HomeLoading());
    }

    final result = await _getTrendingUseCase(limit: _pageSize, offset: 0);
    
    result.fold(
      (error) {
        if (state is HomeRefreshing || state is HomeLoaded) {
          // Trả về trạng thái cũ nếu lỗi
          if (current is HomeLoaded) emit(current);
        } else {
          emit(HomeError(error));
        }
      },
      (tracks) {
        if (current is HomeLoaded) {
          emit(current.copyWith(
            trendingTracks: tracks,
            currentOffset: tracks.length,
            hasMore: tracks.length >= _pageSize,
          ));
        } else {
          emit(HomeLoaded(trendingTracks: tracks, currentOffset: tracks.length));
        }
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
