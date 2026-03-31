import 'package:equatable/equatable.dart';

abstract class AdminFeedbackEvent extends Equatable {
  const AdminFeedbackEvent();

  @override
  List<Object?> get props => [];
}

class AdminFeedbacksLoaded extends AdminFeedbackEvent {
  const AdminFeedbacksLoaded();
}

class AdminFeedbacksLoadMore extends AdminFeedbackEvent {
  const AdminFeedbacksLoadMore();
}

class AdminFeedbacksStatusFilterChanged extends AdminFeedbackEvent {
  final String? status;

  const AdminFeedbacksStatusFilterChanged(this.status);

  @override
  List<Object?> get props => [status];
}

class AdminFeedbacksCategoryFilterChanged extends AdminFeedbackEvent {
  final String? category;

  const AdminFeedbacksCategoryFilterChanged(this.category);

  @override
  List<Object?> get props => [category];
}

class AdminFeedbackHandleRequested extends AdminFeedbackEvent {
  final String feedbackId;
  final String reply;
  final String status;

  const AdminFeedbackHandleRequested({
    required this.feedbackId,
    required this.reply,
    required this.status,
  });

  @override
  List<Object?> get props => [feedbackId, reply, status];
}

class AdminFeedbackAnalyticsLoaded extends AdminFeedbackEvent {
  final int days;

  const AdminFeedbackAnalyticsLoaded({this.days = 7});

  @override
  List<Object?> get props => [days];
}
