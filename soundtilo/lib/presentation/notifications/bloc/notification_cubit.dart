import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soundtilo/core/realtime/notification_realtime_service.dart';
import 'package:soundtilo/data/models/notification_model.dart';
import 'package:soundtilo/domain/repository/notification_repository.dart';
import 'package:soundtilo/presentation/notifications/bloc/notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository _repository;
  final NotificationRealtimeService _realtimeService;
  StreamSubscription<Map<String, dynamic>>? _realtimeSub;

  NotificationCubit(this._repository, this._realtimeService)
    : super(const NotificationState.initial());

  Future<void> onAuthenticated() async {
    await refreshUnreadCount();
    await refreshInbox();
    await _startRealtime();
  }

  Future<void> onUnauthenticated() async {
    await _realtimeSub?.cancel();
    _realtimeSub = null;
    await _realtimeService.disconnect();
    emit(const NotificationState.initial());
  }

  Future<void> refreshInbox() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _repository.getInbox(page: 1, pageSize: 50);
    result.fold(
      (error) => emit(state.copyWith(isLoading: false, error: error)),
      (items) => emit(
        state.copyWith(isLoading: false, items: items, clearError: true),
      ),
    );
  }

  Future<void> refreshUnreadCount() async {
    final result = await _repository.getUnreadCount();
    result.fold(
      (error) => emit(state.copyWith(error: error)),
      (count) => emit(state.copyWith(unreadCount: count, clearError: true)),
    );
  }

  Future<void> markAsRead(String notificationId) async {
    final result = await _repository.markAsRead(notificationId);
    result.fold((error) => emit(state.copyWith(error: error)), (_) {
      final updated = state.items
          .map(
            (e) => e.id == notificationId
                ? NotificationModel(
                    id: e.id,
                    type: e.type,
                    source: e.source,
                    title: e.title,
                    message: e.message,
                    metadataJson: e.metadataJson,
                    isRead: true,
                    createdAt: e.createdAt,
                    readAt: DateTime.now(),
                    expiresAt: e.expiresAt,
                  )
                : e,
          )
          .toList(growable: false);
      final nextUnread = (state.unreadCount - 1).clamp(0, 1 << 30);
      emit(
        state.copyWith(
          items: updated,
          unreadCount: nextUnread,
          clearError: true,
        ),
      );
    });
  }

  Future<void> markAllAsRead() async {
    final result = await _repository.markAllAsRead();
    result.fold((error) => emit(state.copyWith(error: error)), (_) {
      final now = DateTime.now();
      final updated = state.items
          .map(
            (e) => NotificationModel(
              id: e.id,
              type: e.type,
              source: e.source,
              title: e.title,
              message: e.message,
              metadataJson: e.metadataJson,
              isRead: true,
              createdAt: e.createdAt,
              readAt: now,
              expiresAt: e.expiresAt,
            ),
          )
          .toList(growable: false);
      emit(state.copyWith(items: updated, unreadCount: 0, clearError: true));
    });
  }

  Future<void> _startRealtime() async {
    emit(state.copyWith(isConnectingRealtime: true));

    await _realtimeSub?.cancel();
    _realtimeSub = _realtimeService.events.listen((payload) {
      final incoming = NotificationModel.fromJson(payload);
      final exists = state.items.any((e) => e.id == incoming.id);
      if (exists) {
        return;
      }

      final merged = [incoming, ...state.items];
      emit(
        state.copyWith(
          items: merged,
          unreadCount: state.unreadCount + (incoming.isRead ? 0 : 1),
          latestRealtimeNotification: incoming,
          realtimeArrivalVersion: state.realtimeArrivalVersion + 1,
          clearError: true,
        ),
      );
    });

    try {
      await _realtimeService.connect();
      emit(state.copyWith(isConnectingRealtime: false));
    } catch (e) {
      emit(
        state.copyWith(
          isConnectingRealtime: false,
          error: 'Khong the ket noi realtime: $e',
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _realtimeSub?.cancel();
    await _realtimeService.disconnect();
    return super.close();
  }
}
