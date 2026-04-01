import 'package:dartz/dartz.dart';
import 'package:soundtilo/domain/entities/feedback_entity.dart';
import 'package:soundtilo/domain/repository/feedback_repository.dart';

// ─── User: Tạo feedback ───────────────────────────────────────────────────────

class CreateFeedbackUseCase {
  final FeedbackRepository repository;

  CreateFeedbackUseCase(this.repository);

  Future<Either<String, void>> call({
    required String category,
    required String priority,
    required String title,
    required String content,
    String? deviceInfo,
    String? appVersion,
    String? platform,
  }) {
    return repository.createFeedback(
      category: category,
      priority: priority,
      title: title,
      content: content,
      deviceInfo: deviceInfo,
      appVersion: appVersion,
      platform: platform,
    );
  }
}

// ─── User: Xem feedback của mình ─────────────────────────────────────────────

class GetMyFeedbacksUseCase {
  final FeedbackRepository repository;

  GetMyFeedbacksUseCase(this.repository);

  Future<Either<String, (List<FeedbackEntity>, int)>> call({
    String? status,
    int page = 1,
    int pageSize = 10,
  }) {
    return repository.getMyFeedbacks(
      status: status,
      page: page,
      pageSize: pageSize,
    );
  }
}

// ─── Admin: Xem tất cả feedback ──────────────────────────────────────────────

class AdminGetFeedbacksUseCase {
  final FeedbackRepository repository;

  AdminGetFeedbacksUseCase(this.repository);

  Future<Either<String, (List<FeedbackEntity>, int)>> call({
    String? status,
    String? category,
    int page = 1,
    int pageSize = 10,
  }) {
    return repository.adminGetFeedbacks(
      status: status,
      category: category,
      page: page,
      pageSize: pageSize,
    );
  }
}

// ─── Admin: Xử lý feedback ───────────────────────────────────────────────────

class HandleFeedbackUseCase {
  final FeedbackRepository repository;

  HandleFeedbackUseCase(this.repository);

  Future<Either<String, void>> call({
    required String feedbackId,
    required String reply,
    required String status,
  }) {
    return repository.handleFeedback(
      feedbackId: feedbackId,
      reply: reply,
      status: status,
    );
  }
}

// ─── Admin: Analytics ─────────────────────────────────────────────────────────

class GetFeedbackAnalyticsUseCase {
  final FeedbackRepository repository;

  GetFeedbackAnalyticsUseCase(this.repository);

  Future<Either<String, Map<String, dynamic>>> call({int days = 7}) {
    return repository.getAnalytics(days: days);
  }
}
