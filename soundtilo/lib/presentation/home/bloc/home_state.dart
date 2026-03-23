import 'package:equatable/equatable.dart';
import 'package:soundtilo/domain/entities/track_entity.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<TrackEntity> trendingTracks;
  final List<TrackEntity> tagTracks; // Thêm danh sách nhạc theo tag
  final String selectedTag; // Thêm tag đang chọn
  final int currentOffset;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isTagLoading; // Trạng thái load của tag

  const HomeLoaded({
    required this.trendingTracks,
    this.tagTracks = const [],
    this.selectedTag = 'pop',
    this.currentOffset = 0,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.isTagLoading = false,
  });

  HomeLoaded copyWith({
    List<TrackEntity>? trendingTracks,
    List<TrackEntity>? tagTracks,
    String? selectedTag,
    int? currentOffset,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isTagLoading,
  }) {
    return HomeLoaded(
      trendingTracks: trendingTracks ?? this.trendingTracks,
      tagTracks: tagTracks ?? this.tagTracks,
      selectedTag: selectedTag ?? this.selectedTag,
      currentOffset: currentOffset ?? this.currentOffset,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isTagLoading: isTagLoading ?? this.isTagLoading,
    );
  }

  @override
  List<Object?> get props => [
        trendingTracks,
        tagTracks,
        selectedTag,
        currentOffset,
        hasMore,
        isLoadingMore,
        isTagLoading,
      ];
}

class HomeRefreshing extends HomeState {
  final List<TrackEntity> trendingTracks;
  final int currentOffset;
  final bool hasMore;

  const HomeRefreshing({
    required this.trendingTracks,
    this.currentOffset = 0,
    this.hasMore = true,
  });

  @override
  List<Object?> get props => [trendingTracks, currentOffset, hasMore];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
