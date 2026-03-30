import 'package:dartz/dartz.dart';
import 'package:soundtilo/domain/entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<Either<String, List<NotificationEntity>>> getInbox({
    int page = 1,
    int pageSize = 20,
    bool? isRead,
  });

  Future<Either<String, int>> getUnreadCount();
  Future<Either<String, void>> markAsRead(String notificationId);
  Future<Either<String, void>> markAllAsRead();
}
