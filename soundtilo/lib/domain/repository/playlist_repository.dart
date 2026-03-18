import 'package:dartz/dartz.dart';
import 'package:soundtilo/domain/entities/playlist_detail_entity.dart';
import 'package:soundtilo/domain/entities/playlist_entity.dart';

abstract class PlaylistRepository {
  Future<Either<String, List<PlaylistEntity>>> getMyPlaylists();
  Future<Either<String, PlaylistDetailEntity>> getPlaylistDetail(String id);
  Future<Either<String, PlaylistEntity>> createPlaylist({
    required String name,
    String? description,
    bool isPublic = false,
  });
  Future<Either<String, PlaylistEntity>> updatePlaylist(
    String id, {
    String? name,
    String? description,
    bool? isPublic,
  });
  Future<Either<String, void>> deletePlaylist(String id);
  Future<Either<String, void>> addTrack(
    String playlistId,
    String trackExternalId,
  );
  Future<Either<String, void>> removeTrack(
    String playlistId,
    String trackExternalId,
  );
  Future<Either<String, void>> reorderTracks(
    String playlistId,
    List<String> trackExternalIds,
  );
}
