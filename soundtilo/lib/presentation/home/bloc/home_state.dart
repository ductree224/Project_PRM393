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
  final List<AlbumModel> adminAlbums;

  const HomeLoaded({
    required this.trendingTracks,
    this.adminAlbums = const [],
  });

  @override
  List<Object?> get props => [trendingTracks, adminAlbums];
}

class HomeRefreshing extends HomeState {
  final List<TrackEntity> trendingTracks;
  final List<AlbumModel> adminAlbums;

  const HomeRefreshing({
    required this.trendingTracks,
    this.adminAlbums = const [],
  });

  @override
  List<Object?> get props => [trendingTracks, adminAlbums];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
