import 'package:dartz/dartz.dart';
import 'package:soundtilo/domain/entities/feedback_entity.dart';

abstract class FeedbackRepository {
  // User: tạo feedback mới
  Future<Either<String, void>> createFeedback({
    required String category,
    required String priority,
    required String title,
    required String content,
    String? deviceInfo,
    String? appVersion,
    String? platform,
  });

  // User: xem danh sách feedback của chính mình
  Future<Either<String, (List<FeedbackEntity>, int)>> getMyFeedbacks({
    String? status,
    int page = 1,
    int pageSize = 10,
  });

  // Admin: xem tất cả feedback (có filter)
  Future<Either<String, (List<FeedbackEntity>, int)>> adminGetFeedbacks({
    String? status,
    String? category,
    int page = 1,
    int pageSize = 10,
  });

  // Admin: xử lý feedback (reply + đổi status)
  Future<Either<String, void>> handleFeedback({
    required String feedbackId,
    required String reply,
    required String status,
  });

  // Admin: analytics
  Future<Either<String, Map<String, dynamic>>> getAnalytics({int days = 7});
}
