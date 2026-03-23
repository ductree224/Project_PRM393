import 'package:dio/dio.dart';

class CommentRemoteDataSource {
  final Dio _dio;

  CommentRemoteDataSource(this._dio);

  Future<Map<String, dynamic>> getComments(
    String trackExternalId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get(
      '/api/comments/$trackExternalId',
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> addComment(
    String trackExternalId,
    String content,
  ) async {
    final response = await _dio.post(
      '/api/comments/$trackExternalId',
      data: {'content': content},
    );
    return response.data;
  }

  Future<void> deleteComment(String commentId) async {
    await _dio.delete('/api/comments/$commentId');
  }
}
