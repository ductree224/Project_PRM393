import 'package:equatable/equatable.dart';

abstract class FeedbackEvent extends Equatable {
  const FeedbackEvent();

  @override
  List<Object?> get props => [];
}

// ─── Create Feedback ──────────────────────────────────────────────────────────

class FeedbackFormSubmitted extends FeedbackEvent {
  final String category;
  final String priority;
  final String title;
  final String content;

  const FeedbackFormSubmitted({
    required this.category,
    required this.priority,
    required this.title,
    required this.content,
  });

  @override
  List<Object?> get props => [category, priority, title, content];
}

// ─── My Feedbacks ─────────────────────────────────────────────────────────────

class MyFeedbacksLoaded extends FeedbackEvent {
  const MyFeedbacksLoaded();
}

class MyFeedbacksLoadMore extends FeedbackEvent {
  const MyFeedbacksLoadMore();
}

class MyFeedbacksStatusFilterChanged extends FeedbackEvent {
  final String? status;

  const MyFeedbacksStatusFilterChanged(this.status);

  @override
  List<Object?> get props => [status];
}

// ─── Reset form submit state after navigation ────────────────────────────────

class FeedbackFormReset extends FeedbackEvent {
  const FeedbackFormReset();
}
