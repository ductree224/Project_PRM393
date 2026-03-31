import 'package:dio/dio.dart';

class NotificationRemoteDataSource {
  final Dio _dio;

  NotificationRemoteDataSource(this._dio);

  Future<Map<String, dynamic>> getInbox({
    int page = 1,
    int pageSize = 20,
    bool? isRead,
  }) async {
    final response = await _dio.get(
      '/api/notifications/inbox',
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        ...?isRead == null ? null : {'isRead': isRead},
      },
    );

    return response.data as Map<String, dynamic>;
  }

  Future<int> getUnreadCount() async {
    final response = await _dio.get('/api/notifications/unread-count');
    final data = response.data as Map<String, dynamic>;
    return (data['unreadCount'] as num?)?.toInt() ?? 0;
  }

  Future<void> markAsRead(String notificationId) async {
    await _dio.post('/api/notifications/$notificationId/read');
  }

  Future<void> markAllAsRead() async {
    await _dio.post('/api/notifications/read-all');
  }
}
