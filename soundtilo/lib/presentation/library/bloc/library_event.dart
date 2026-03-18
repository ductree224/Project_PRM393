import 'package:equatable/equatable.dart';

abstract class LibraryEvent extends Equatable {
  const LibraryEvent();

  @override
  List<Object?> get props => [];
}

class LibraryLoad extends LibraryEvent {}

class LibraryCreatePlaylist extends LibraryEvent {
  final String name;
  final String? description;

  const LibraryCreatePlaylist({required this.name, this.description});

  @override
  List<Object?> get props => [name, description];
}

class LibraryDeletePlaylist extends LibraryEvent {
  final String playlistId;

  const LibraryDeletePlaylist(this.playlistId);

  @override
  List<Object?> get props => [playlistId];
}

class LibraryUpdatePlaylist extends LibraryEvent {
  final String playlistId;
  final String? name;
  final String? description;
  final bool? isPublic;

  const LibraryUpdatePlaylist({
    required this.playlistId,
    this.name,
    this.description,
    this.isPublic,
  });

  @override
  List<Object?> get props => [playlistId, name, description, isPublic];
}

class LibraryAddTrackToPlaylist extends LibraryEvent {
  final String playlistId;
  final String trackExternalId;

  const LibraryAddTrackToPlaylist({
    required this.playlistId,
    required this.trackExternalId,
  });

  @override
  List<Object?> get props => [playlistId, trackExternalId];
}

class LibraryRemoveTrackFromPlaylist extends LibraryEvent {
  final String playlistId;
  final String trackExternalId;

  const LibraryRemoveTrackFromPlaylist({
    required this.playlistId,
    required this.trackExternalId,
  });

  @override
  List<Object?> get props => [playlistId, trackExternalId];
}

class LibraryToggleFavorite extends LibraryEvent {
  final String trackExternalId;

  const LibraryToggleFavorite(this.trackExternalId);

  @override
  List<Object?> get props => [trackExternalId];
}
