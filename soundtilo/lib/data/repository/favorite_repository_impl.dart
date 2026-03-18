import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:soundtilo/data/sources/favorite_remote_data_source.dart';
import 'package:soundtilo/domain/repository/favorite_repository.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  final FavoriteRemoteDataSource _remoteDataSource;

  FavoriteRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<String, List<String>>> getFavorites({int page = 1, int pageSize = 20}) async {
    try {
      final data = await _remoteDataSource.getFavorites(page: page, pageSize: pageSize);
      final favorites = (data['favorites'] as List?)
              ?.map((f) => f['trackExternalId']?.toString() ?? '')
              .where((id) => id.isNotEmpty)
              .toList() ??
          [];
      return Right(favorites);
    } on DioException catch (e) {
      return Left(e.response?.data?['message'] ?? 'Không thể tải danh sách yêu thích.');
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }

  @override
  Future<Either<String, bool>> toggleFavorite(String trackExternalId) async {
    try {
      final isFavorite = await _remoteDataSource.toggleFavorite(trackExternalId);
      return Right(isFavorite);
    } on DioException catch (e) {
      return Left(e.response?.data?['message'] ?? 'Không thể cập nhật yêu thích.');
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }

  @override
  Future<Either<String, bool>> isFavorite(String trackExternalId) async {
    try {
      final isFav = await _remoteDataSource.isFavorite(trackExternalId);
      return Right(isFav);
    } on DioException catch (e) {
      return Left(e.response?.data?['message'] ?? 'Không thể kiểm tra trạng thái yêu thích.');
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }
}
