import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:soundtilo/data/models/notification_model.dart';
import 'package:soundtilo/data/sources/notification_remote_data_source.dart';
import 'package:soundtilo/domain/entities/notification_entity.dart';
import 'package:soundtilo/domain/repository/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource _remote;

  NotificationRepositoryImpl(this._remote);

  @override
  Future<Either<String, List<NotificationEntity>>> getInbox({
    int page = 1,
    int pageSize = 20,
    bool? isRead,
  }) async {
    try {
      final data = await _remote.getInbox(page: page, pageSize: pageSize, isRead: isRead);
      final raw = (data['notifications'] as List?) ?? const [];
      final items = raw
          .whereType<Map<String, dynamic>>()
          .map(NotificationModel.fromJson)
          .toList(growable: false);
      return Right(items);
    } on DioException catch (e) {
      return Left(e.response?.data?['message']?.toString() ?? 'Khong the tai thong bao.');
    } catch (e) {
      return Left('Da xay ra loi: $e');
    }
  }

  @override
  Future<Either<String, int>> getUnreadCount() async {
    try {
      final count = await _remote.getUnreadCount();
      return Right(count);
    } on DioException catch (e) {
      return Left(e.response?.data?['message']?.toString() ?? 'Khong the tai so thong bao chua doc.');
    } catch (e) {
      return Left('Da xay ra loi: $e');
    }
  }

  @override
  Future<Either<String, void>> markAsRead(String notificationId) async {
    try {
      await _remote.markAsRead(notificationId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(e.response?.data?['message']?.toString() ?? 'Khong the cap nhat thong bao.');
    } catch (e) {
      return Left('Da xay ra loi: $e');
    }
  }

  @override
  Future<Either<String, void>> markAllAsRead() async {
    try {
      await _remote.markAllAsRead();
      return const Right(null);
    } on DioException catch (e) {
      return Left(e.response?.data?['message']?.toString() ?? 'Khong the cap nhat thong bao.');
    } catch (e) {
      return Left('Da xay ra loi: $e');
    }
  }
}
