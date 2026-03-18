import 'package:dartz/dartz.dart';
import 'package:soundtilo/domain/entities/playlist_detail_entity.dart';
import 'package:soundtilo/domain/entities/playlist_entity.dart';
import 'package:soundtilo/domain/repository/playlist_repository.dart';

class GetPlaylistsUseCase {
  final PlaylistRepository repository;

  GetPlaylistsUseCase(this.repository);

  Future<Either<String, List<PlaylistEntity>>> call() {
    return repository.getMyPlaylists();
  }
}

class GetPlaylistDetailUseCase {
  final PlaylistRepository repository;

  GetPlaylistDetailUseCase(this.repository);

  Future<Either<String, PlaylistDetailEntity>> call(String playlistId) {
    return repository.getPlaylistDetail(playlistId);
  }
}

class CreatePlaylistUseCase {
  final PlaylistRepository repository;

  CreatePlaylistUseCase(this.repository);

  Future<Either<String, PlaylistEntity>> call({
    required String name,
    String? description,
    bool isPublic = false,
  }) {
    return repository.createPlaylist(
      name: name,
      description: description,
      isPublic: isPublic,
    );
  }
}

class UpdatePlaylistUseCase {
  final PlaylistRepository repository;

  UpdatePlaylistUseCase(this.repository);

  Future<Either<String, PlaylistEntity>> call(
    String playlistId, {
    String? name,
    String? description,
    bool? isPublic,
  }) {
    return repository.updatePlaylist(
      playlistId,
      name: name,
      description: description,
      isPublic: isPublic,
    );
  }
}

class DeletePlaylistUseCase {
  final PlaylistRepository repository;

  DeletePlaylistUseCase(this.repository);

  Future<Either<String, void>> call(String playlistId) {
    return repository.deletePlaylist(playlistId);
  }
}

class AddTrackToPlaylistUseCase {
  final PlaylistRepository repository;

  AddTrackToPlaylistUseCase(this.repository);

  Future<Either<String, void>> call(String playlistId, String trackExternalId) {
    return repository.addTrack(playlistId, trackExternalId);
  }
}

class RemoveTrackFromPlaylistUseCase {
  final PlaylistRepository repository;

  RemoveTrackFromPlaylistUseCase(this.repository);

  Future<Either<String, void>> call(String playlistId, String trackExternalId) {
    return repository.removeTrack(playlistId, trackExternalId);
  }
}

class ReorderTracksInPlaylistUseCase {
  final PlaylistRepository repository;

  ReorderTracksInPlaylistUseCase(this.repository);

  Future<Either<String, void>> call(
    String playlistId,
    List<String> trackExternalIds,
  ) {
    return repository.reorderTracks(playlistId, trackExternalIds);
  }
}
