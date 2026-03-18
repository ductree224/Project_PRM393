import 'package:dio/dio.dart';

class HistoryRemoteDataSource {
  final Dio _dio;

  HistoryRemoteDataSource(this._dio);

  Future<Map<String, dynamic>> getHistory({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get(
      '/api/history',
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    return response.data;
  }

  Future<void> recordListen({
    required String trackExternalId,
    required int durationListened,
    required bool completed,
  }) async {
    await _dio.post(
      '/api/history',
      data: {
        'trackExternalId': trackExternalId,
        'durationListened': durationListened,
        'completed': completed,
      },
    );
  }

  Future<int> deleteHistory(List<String> historyIds) async {
    final response = await _dio.delete(
      '/api/history',
      data: {'historyIds': historyIds},
    );
    return (response.data['deletedCount'] ?? response.data['DeletedCount'] ?? 0)
        as int;
  }
}
