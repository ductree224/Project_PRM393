import 'package:soundtilo/domain/entities/comment_entity.dart';

abstract class CommentState {}

class CommentInitial extends CommentState {}

class CommentLoading extends CommentState {}

class CommentLoaded extends CommentState {
  final List<CommentEntity> comments;
  final int totalCount;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isSubmitting;

  CommentLoaded({
    required this.comments,
    required this.totalCount,
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.isSubmitting = false,
  });

  CommentLoaded copyWith({
    List<CommentEntity>? comments,
    int? totalCount,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isSubmitting,
  }) {
    return CommentLoaded(
      comments: comments ?? this.comments,
      totalCount: totalCount ?? this.totalCount,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class CommentError extends CommentState {
  final String message;
  CommentError(this.message);
}
