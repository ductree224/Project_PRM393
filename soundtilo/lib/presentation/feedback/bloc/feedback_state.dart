import 'package:equatable/equatable.dart';
import 'package:soundtilo/domain/entities/feedback_entity.dart';

enum FeedbackFormStatus { initial, submitting, success, failure }

enum MyFeedbacksStatus { initial, loading, loaded, error }

class FeedbackState extends Equatable {
  // ─── Form state ─────────────────────────────────────────────────────────────
  final FeedbackFormStatus formStatus;
  final String? formError;

  // ─── My Feedbacks list state ────────────────────────────────────────────────
  final MyFeedbacksStatus listStatus;
  final List<FeedbackEntity> feedbacks;
  final int total;
  final int page;
  final int pageSize;
  final String? statusFilter;
  final bool isLoadingMore;
  final bool hasMore;
  final String? listError;

  const FeedbackState({
    this.formStatus = FeedbackFormStatus.initial,
    this.formError,
    this.listStatus = MyFeedbacksStatus.initial,
    this.feedbacks = const [],
    this.total = 0,
    this.page = 1,
    this.pageSize = 10,
    this.statusFilter,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.listError,
  });

  FeedbackState copyWith({
    FeedbackFormStatus? formStatus,
    String? formError,
    MyFeedbacksStatus? listStatus,
    List<FeedbackEntity>? feedbacks,
    int? total,
    int? page,
    int? pageSize,
    String? statusFilter,
    bool? isLoadingMore,
    bool? hasMore,
    String? listError,
  }) {
    return FeedbackState(
      formStatus: formStatus ?? this.formStatus,
      formError: formError,
      listStatus: listStatus ?? this.listStatus,
      feedbacks: feedbacks ?? this.feedbacks,
      total: total ?? this.total,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      statusFilter: statusFilter ?? this.statusFilter,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      listError: listError,
    );
  }

  @override
  List<Object?> get props => [
        formStatus,
        formError,
        listStatus,
        feedbacks,
        total,
        page,
        statusFilter,
        isLoadingMore,
        hasMore,
        listError,
      ];
}
