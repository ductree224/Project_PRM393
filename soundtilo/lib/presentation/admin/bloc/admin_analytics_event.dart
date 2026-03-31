import 'package:equatable/equatable.dart';

abstract class AdminAnalyticsEvent extends Equatable {
  const AdminAnalyticsEvent();

  @override
  List<Object?> get props => [];
}

class AdminAnalyticsStarted extends AdminAnalyticsEvent {
  const AdminAnalyticsStarted();
}

class AdminAnalyticsRefresh extends AdminAnalyticsEvent {
  const AdminAnalyticsRefresh();
}

class AdminAnalyticsDateRangeChanged extends AdminAnalyticsEvent {
  final String from;
  final String to;
  const AdminAnalyticsDateRangeChanged({required this.from, required this.to});

  @override
  List<Object?> get props => [from, to];
}
