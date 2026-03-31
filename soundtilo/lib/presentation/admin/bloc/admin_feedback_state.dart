import 'package:equatable/equatable.dart';
import 'package:soundtilo/domain/entities/feedback_entity.dart';

enum AdminFeedbacksStatus { initial, loading, loaded, error }

enum AdminFeedbackHandleStatus { idle, processing, success, failure }

class AdminFeedbackState extends Equatable {
  final AdminFeedbacksStatus status;
  final List<FeedbackEntity> feedbacks;
  final int total;
  final int page;
  final int pageSize;
  final String? statusFilter;
  final String? categoryFilter;
  final bool isLoadingMore;
  final bool hasMore;
  final String? errorMessage;

  // Handle state
  final AdminFeedbackHandleStatus handleStatus;
  final String? handleError;

  // Analytics
  final Map<String, dynamic>? analytics;
  final bool isLoadingAnalytics;

  const AdminFeedbackState({
    this.status = AdminFeedbacksStatus.initial,
    this.feedbacks = const [],
    this.total = 0,
    this.page = 1,
    this.pageSize = 10,
    this.statusFilter,
    this.categoryFilter,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.errorMessage,
    this.handleStatus = AdminFeedbackHandleStatus.idle,
    this.handleError,
    this.analytics,
    this.isLoadingAnalytics = false,
  });

  AdminFeedbackState copyWith({
    AdminFeedbacksStatus? status,
    List<FeedbackEntity>? feedbacks,
    int? total,
    int? page,
    int? pageSize,
    String? statusFilter,
    String? categoryFilter,
    bool? isLoadingMore,
    bool? hasMore,
    String? errorMessage,
    AdminFeedbackHandleStatus? handleStatus,
    String? handleError,
    Map<String, dynamic>? analytics,
    bool? isLoadingAnalytics,
  }) {
    return AdminFeedbackState(
      status: status ?? this.status,
      feedbacks: feedbacks ?? this.feedbacks,
      total: total ?? this.total,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      statusFilter: statusFilter ?? this.statusFilter,
      categoryFilter: categoryFilter ?? this.categoryFilter,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage,
      handleStatus: handleStatus ?? this.handleStatus,
      handleError: handleError,
      analytics: analytics ?? this.analytics,
      isLoadingAnalytics: isLoadingAnalytics ?? this.isLoadingAnalytics,
    );
  }

  @override
  List<Object?> get props => [
        status,
        feedbacks,
        total,
        page,
        statusFilter,
        categoryFilter,
        isLoadingMore,
        hasMore,
        errorMessage,
        handleStatus,
        handleError,
        analytics,
        isLoadingAnalytics,
      ];
}
