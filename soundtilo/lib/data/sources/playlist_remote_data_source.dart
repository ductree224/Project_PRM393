import 'package:dio/dio.dart';
import 'package:soundtilo/data/models/playlist_detail_model.dart';
import 'package:soundtilo/data/models/playlist_model.dart';

class PlaylistRemoteDataSource {
  final Dio _dio;

  PlaylistRemoteDataSource(this._dio);

  Future<List<PlaylistModel>> getMyPlaylists() async {
    final response = await _dio.get('/api/playlists');
    return (response.data as List)
        .map((p) => PlaylistModel.fromJson(p))
        .toList();
  }

  Future<PlaylistDetailModel> getPlaylistDetail(String id) async {
    final response = await _dio.get('/api/playlists/$id');
    return PlaylistDetailModel.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }

  Future<PlaylistModel> createPlaylist({
    required String name,
    String? description,
    bool isPublic = false,
  }) async {
    final response = await _dio.post(
      '/api/playlists',
      data: {'name': name, 'description': description, 'isPublic': isPublic},
    );
    return PlaylistModel.fromJson(response.data);
  }

  Future<PlaylistModel> updatePlaylist(
    String id, {
    String? name,
    String? description,
    bool? isPublic,
  }) async {
    final response = await _dio.put(
      '/api/playlists/$id',
      data: {
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (isPublic != null) 'isPublic': isPublic,
      },
    );
    return PlaylistModel.fromJson(response.data);
  }

  Future<void> deletePlaylist(String id) async {
    await _dio.delete('/api/playlists/$id');
  }

  Future<void> addTrack(String playlistId, String trackExternalId) async {
    await _dio.post(
      '/api/playlists/$playlistId/tracks',
      data: {'trackExternalId': trackExternalId},
    );
  }

  Future<void> removeTrack(String playlistId, String trackExternalId) async {
    await _dio.delete('/api/playlists/$playlistId/tracks/$trackExternalId');
  }

  Future<void> reorderTracks(
    String playlistId,
    List<String> trackExternalIds,
  ) async {
    await _dio.put(
      '/api/playlists/$playlistId/tracks/reorder',
      data: {'trackExternalIds': trackExternalIds},
    );
  }
}
