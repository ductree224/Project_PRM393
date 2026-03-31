import 'package:dio/dio.dart';

class FeedbackRemoteDataSource {
  final Dio _dio;

  FeedbackRemoteDataSource(this._dio);

  /// POST /api/feedbacks — User tạo feedback
  Future<void> createFeedback(Map<String, dynamic> body) async {
    await _dio.post('/api/feedbacks', data: body);
  }

  /// GET /api/feedbacks/me — User xem feedback của mình
  Future<Map<String, dynamic>> getMyFeedbacks({
    String? status,
    int page = 1,
    int pageSize = 10,
  }) async {
    final response = await _dio.get(
      '/api/feedbacks/me',
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        if (status != null) 'status': status,
      },
    );
    return response.data;
  }

  /// GET /api/feedbacks — Admin xem tất cả
  Future<Map<String, dynamic>> adminGetFeedbacks({
    String? status,
    String? category,
    int page = 1,
    int pageSize = 10,
  }) async {
    final response = await _dio.get(
      '/api/feedbacks',
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        if (status != null) 'status': status,
        if (category != null) 'category': category,
      },
    );
    return response.data;
  }

  /// PUT /api/feedbacks/{id}/handle — Admin xử lý
  Future<void> handleFeedback(
    String feedbackId,
    Map<String, dynamic> body,
  ) async {
    await _dio.put('/api/feedbacks/$feedbackId/handle', data: body);
  }

  /// GET /api/feedbacks/analytics — Analytics
  Future<Map<String, dynamic>> getAnalytics({int days = 7}) async {
    final response = await _dio.get(
      '/api/feedbacks/analytics',
      queryParameters: {'days': days},
    );
    return response.data;
  }
}
