import 'package:dio/dio.dart';

class LyricsRemoteDataSource {
  final Dio _dio;

  LyricsRemoteDataSource(this._dio);

  Future<String?> getLyrics({required String artist, required String title}) async {
    final response = await _dio.get('/api/lyrics', queryParameters: {
      'artist': artist,
      'title': title,
    });
    return response.data['lyrics'];
  }
}
