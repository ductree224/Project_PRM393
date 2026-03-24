import 'package:equatable/equatable.dart';
import 'package:soundtilo/data/models/album_model.dart';
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
  final List<TrackEntity> tagTracks;
  final List<AlbumModel> adminAlbums;

  final String selectedTag; // Thêm tag đang chọn
  final int currentOffset;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isTagLoading; // Trạng thái load của tag

  const HomeLoaded({
    required this.trendingTracks,
    this.adminAlbums = const [],
    this.tagTracks = const [],
    this.selectedTag = 'pop',
    this.currentOffset = 0,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.isTagLoading = false,
  });

  HomeLoaded copyWith({
    List<TrackEntity>? trendingTracks,
    List<AlbumModel>? adminAlbums,
    List<TrackEntity>? tagTracks,
    String? selectedTag,
    int? currentOffset,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isTagLoading,
  }) {
    return HomeLoaded(
      trendingTracks: trendingTracks ?? this.trendingTracks,
      adminAlbums: adminAlbums ?? this.adminAlbums,
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
    adminAlbums,
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
  final List<AlbumModel> adminAlbums;

  const HomeRefreshing({
    required this.trendingTracks,
    this.currentOffset = 0,
    this.hasMore = true,
    this.adminAlbums = const [],
  });

  @override
  List<Object?> get props => [
    trendingTracks,
    currentOffset,
    hasMore,
    adminAlbums,
  ];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
