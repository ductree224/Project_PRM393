import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:soundtilo/data/sources/feedback_remote_data_source.dart';
import 'package:soundtilo/domain/entities/feedback_entity.dart';
import 'package:soundtilo/domain/repository/feedback_repository.dart';

class FeedbackRepositoryImpl implements FeedbackRepository {
  final FeedbackRemoteDataSource _remoteDataSource;

  FeedbackRepositoryImpl(this._remoteDataSource);

  FeedbackEntity _mapToEntity(Map<String, dynamic> json) {
    return FeedbackEntity(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      category: json['category']?.toString() ?? 'general',
      priority: json['priority']?.toString() ?? 'medium',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      deviceInfo: json['deviceInfo']?.toString(),
      appVersion: json['appVersion']?.toString(),
      platform: json['platform']?.toString(),
      attachmentUrl: json['attachmentUrl']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      adminReply: json['adminReply']?.toString(),
      handledByAdminId: json['handledByAdminId']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      handledAt: json['handledAt'] != null
          ? DateTime.tryParse(json['handledAt'].toString())
          : null,
    );
  }

  @override
  Future<Either<String, void>> createFeedback({
    required String category,
    required String priority,
    required String title,
    required String content,
    String? deviceInfo,
    String? appVersion,
    String? platform,
  }) async {
    try {
      await _remoteDataSource.createFeedback({
        'category': category,
        'priority': priority,
        'title': title,
        'content': content,
        if (deviceInfo != null) 'deviceInfo': deviceInfo,
        if (appVersion != null) 'appVersion': appVersion,
        if (platform != null) 'platform': platform,
      });
      return const Right(null);
    } on DioException catch (e) {
      return Left(
        (e.response?.data is Map ? e.response?.data['message'] : null) ??
            'Không thể gửi phản hồi.',
      );
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }

  @override
  Future<Either<String, (List<FeedbackEntity>, int)>> getMyFeedbacks({
    String? status,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final data = await _remoteDataSource.getMyFeedbacks(
        status: status,
        page: page,
        pageSize: pageSize,
      );
      final items = (data['items'] as List?)
              ?.map((e) => _mapToEntity(e as Map<String, dynamic>))
              .toList() ??
          [];
      final total = (data['total'] as num?)?.toInt() ?? 0;
      return Right((items, total));
    } on DioException catch (e) {
      return Left(
        (e.response?.data is Map ? e.response?.data['message'] : null) ??
            'Không thể tải phản hồi.',
      );
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }

  @override
  Future<Either<String, (List<FeedbackEntity>, int)>> adminGetFeedbacks({
    String? status,
    String? category,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final data = await _remoteDataSource.adminGetFeedbacks(
        status: status,
        category: category,
        page: page,
        pageSize: pageSize,
      );
      final items = (data['items'] as List?)
              ?.map((e) => _mapToEntity(e as Map<String, dynamic>))
              .toList() ??
          [];
      final total = (data['total'] as num?)?.toInt() ?? 0;
      return Right((items, total));
    } on DioException catch (e) {
      return Left(
        (e.response?.data is Map ? e.response?.data['message'] : null) ??
            'Không thể tải danh sách phản hồi.',
      );
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }

  @override
  Future<Either<String, void>> handleFeedback({
    required String feedbackId,
    required String reply,
    required String status,
  }) async {
    try {
      await _remoteDataSource.handleFeedback(feedbackId, {
        'reply': reply,
        'status': status,
      });
      return const Right(null);
    } on DioException catch (e) {
      return Left(
        (e.response?.data is Map ? e.response?.data['message'] : null) ??
            'Không thể xử lý phản hồi.',
      );
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }

  @override
  Future<Either<String, Map<String, dynamic>>> getAnalytics({
    int days = 7,
  }) async {
    try {
      final data = await _remoteDataSource.getAnalytics(days: days);
      return Right(data);
    } on DioException catch (e) {
      return Left(
        (e.response?.data is Map ? e.response?.data['message'] : null) ??
            'Không thể tải analytics.',
      );
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }
}
