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
  final int currentOffset;
  final bool hasMore;
  final bool isLoadingMore;

  const HomeLoaded({
    required this.trendingTracks,
    this.currentOffset = 0,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  HomeLoaded copyWith({
    List<TrackEntity>? trendingTracks,
    int? currentOffset,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return HomeLoaded(
      trendingTracks: trendingTracks ?? this.trendingTracks,
      currentOffset: currentOffset ?? this.currentOffset,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [trendingTracks, currentOffset, hasMore, isLoadingMore];
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
