import 'package:equatable/equatable.dart';
import 'package:soundtilo/domain/entities/playlist_entity.dart';

abstract class LibraryState extends Equatable {
  const LibraryState();

  @override
  List<Object?> get props => [];
}

class LibraryInitial extends LibraryState {}

class LibraryLoading extends LibraryState {}

class LibraryLoaded extends LibraryState {
  final List<PlaylistEntity> playlists;
  final List<String> favoriteTrackIds;

  const LibraryLoaded({
    required this.playlists,
    required this.favoriteTrackIds,
  });

  @override
  List<Object?> get props => [playlists, favoriteTrackIds];
}

class LibraryRefreshing extends LibraryState {
  final List<PlaylistEntity> playlists;
  final List<String> favoriteTrackIds;

  const LibraryRefreshing({
    required this.playlists,
    required this.favoriteTrackIds,
  });

  @override
  List<Object?> get props => [playlists, favoriteTrackIds];
}

class LibraryError extends LibraryState {
  final String message;

  const LibraryError(this.message);

  @override
  List<Object?> get props => [message];
}
