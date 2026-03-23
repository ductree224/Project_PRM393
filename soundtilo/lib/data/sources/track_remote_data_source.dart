import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:soundtilo/data/models/track_model.dart';

List<TrackModel> _parseTrackModels(List<Map<String, dynamic>> rawTracks) {
  return rawTracks.map(TrackModel.fromJson).toList(growable: false);
}

List<Map<String, dynamic>> _normalizeTracks(dynamic payload) {
  final tracks = (payload['tracks'] as List?)
          ?.whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList(growable: false) ??
      const <Map<String, dynamic>>[];
  return tracks;
}

class TrackRemoteDataSource {
  final Dio _dio;

  TrackRemoteDataSource(this._dio);

  Future<List<TrackModel>> search(
    String query, {
    String? source,
    int limit = 20,
    int offset = 0,
    bool cacheOnly = false,
    bool fallbackExternal = true,
  }) async {
    final response = await _dio.get('/api/tracks/search', queryParameters: {
      'q': query,
      ...?source != null ? {'source': source} : null,
      'limit': limit,
      'offset': offset,
      'cacheOnly': cacheOnly,
      'fallbackExternal': fallbackExternal,
    });
    final tracks = _normalizeTracks(response.data);
    if (tracks.isEmpty) {
      return const <TrackModel>[];
    }
    return compute(_parseTrackModels, tracks);
  }

  Future<List<TrackModel>> getTrending({String? genre, String? time, int limit = 20, int offset = 0}) async {
    final response = await _dio.get('/api/tracks/trending', queryParameters: {
      ...?genre != null ? {'genre': genre} : null,
      ...?time != null ? {'time': time} : null,
      'limit': limit,
      'offset': offset,
    });
    final tracks = _normalizeTracks(response.data);
    if (tracks.isEmpty) {
      return const <TrackModel>[];
    }
    return compute(_parseTrackModels, tracks);
  }

  Future<TrackModel> getTrack(String externalId, {String source = 'audius'}) async {
    final response = await _dio.get('/api/tracks/$externalId', queryParameters: {
      'source': source,
    });
    return TrackModel.fromJson(response.data);
  }

  Future<String> getStreamUrl(String trackId) async {
    final response = await _dio.get('/api/tracks/$trackId/stream');
    return response.data['streamUrl'];
  }

  Future<List<TrackModel>> getByTag(String tag, {int limit = 20}) async {
    final response = await _dio.get('/api/tracks/tags/$tag', queryParameters: {
      'limit': limit,
    });
    final tracks = _normalizeTracks(response.data);
    if (tracks.isEmpty) {
      return const <TrackModel>[];
    }
    return compute(_parseTrackModels, tracks);
  }
}
