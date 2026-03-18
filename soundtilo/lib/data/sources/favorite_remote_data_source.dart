import 'package:dio/dio.dart';

class FavoriteRemoteDataSource {
  final Dio _dio;

  FavoriteRemoteDataSource(this._dio);

  Future<Map<String, dynamic>> getFavorites({int page = 1, int pageSize = 20}) async {
    final response = await _dio.get('/api/favorites', queryParameters: {
      'page': page,
      'pageSize': pageSize,
    });
    return response.data;
  }

  Future<bool> toggleFavorite(String trackExternalId) async {
    final response = await _dio.post('/api/favorites/$trackExternalId');
    return response.data['isFavorite'] ?? false;
  }

  Future<bool> isFavorite(String trackExternalId) async {
    final response = await _dio.get('/api/favorites/$trackExternalId/check');
    return response.data['isFavorite'] ?? false;
  }
}
