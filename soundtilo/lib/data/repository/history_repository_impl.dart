import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:soundtilo/data/sources/history_remote_data_source.dart';
import 'package:soundtilo/domain/repository/history_repository.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryRemoteDataSource _remoteDataSource;

  HistoryRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<String, List<Map<String, dynamic>>>> getHistory({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final data = await _remoteDataSource.getHistory(
        page: page,
        pageSize: pageSize,
      );
      final history =
          (data['history'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      return Right(history);
    } on DioException catch (e) {
      return Left(
        (e.response?.data is Map ? e.response?.data['message'] : null) ?? 'Không thể tải lịch sử nghe.',
      );
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }

  @override
  Future<Either<String, void>> recordListen({
    required String trackExternalId,
    required int durationListened,
    required bool completed,
  }) async {
    try {
      await _remoteDataSource.recordListen(
        trackExternalId: trackExternalId,
        durationListened: durationListened,
        completed: completed,
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(
        (e.response?.data is Map ? e.response?.data['message'] : null) ?? 'Không thể ghi nhận lịch sử.',
      );
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }

  @override
  Future<Either<String, int>> deleteHistory(List<String> historyIds) async {
    try {
      final deletedCount = await _remoteDataSource.deleteHistory(historyIds);
      return Right(deletedCount);
    } on DioException catch (e) {
      return Left(
        (e.response?.data is Map ? e.response?.data['message'] : null) ?? 'Không thể xoá lịch sử nghe.',
      );
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }
}
