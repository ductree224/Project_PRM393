import 'package:equatable/equatable.dart';
import 'package:soundtilo/domain/entities/notification_entity.dart';

class NotificationState extends Equatable {
  final bool isLoading;
  final bool isConnectingRealtime;
  final List<NotificationEntity> items;
  final int unreadCount;
  final String? error;
  final NotificationEntity? latestRealtimeNotification;
  final int realtimeArrivalVersion;

  const NotificationState({
    required this.isLoading,
    required this.isConnectingRealtime,
    required this.items,
    required this.unreadCount,
    required this.error,
    required this.latestRealtimeNotification,
    required this.realtimeArrivalVersion,
  });

  const NotificationState.initial()
    : isLoading = false,
      isConnectingRealtime = false,
      items = const [],
      unreadCount = 0,
      error = null,
      latestRealtimeNotification = null,
      realtimeArrivalVersion = 0;

  NotificationState copyWith({
    bool? isLoading,
    bool? isConnectingRealtime,
    List<NotificationEntity>? items,
    int? unreadCount,
    String? error,
    NotificationEntity? latestRealtimeNotification,
    int? realtimeArrivalVersion,
    bool clearError = false,
    bool clearRealtime = false,
  }) {
    return NotificationState(
      isLoading: isLoading ?? this.isLoading,
      isConnectingRealtime: isConnectingRealtime ?? this.isConnectingRealtime,
      items: items ?? this.items,
      unreadCount: unreadCount ?? this.unreadCount,
      error: clearError ? null : (error ?? this.error),
      latestRealtimeNotification: clearRealtime
          ? null
          : (latestRealtimeNotification ?? this.latestRealtimeNotification),
      realtimeArrivalVersion:
          realtimeArrivalVersion ?? this.realtimeArrivalVersion,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isConnectingRealtime,
    items,
    unreadCount,
    error,
    latestRealtimeNotification,
    realtimeArrivalVersion,
  ];
}
