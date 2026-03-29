import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:soundtilo/data/sources/user_remote_data_source.dart';
import 'package:soundtilo/domain/entities/user_entity.dart';
import 'package:soundtilo/domain/repository/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource _dataSource;

  UserRepositoryImpl(this._dataSource);

  @override
  Future<Either<String, UserEntity>> getProfile() async {
    try {
      final user = await _dataSource.getProfile();
      return Right(user);
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = data is Map
          ? data['message']?.toString() ?? 'Không thể tải hồ sơ.'
          : 'Không thể tải hồ sơ.';
      return Left(message);
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }

  @override
  Future<Either<String, UserEntity>> updateProfile({
    String? displayName,
    String? avatarUrl,
  }) async {
    try {
      final user = await _dataSource.updateProfile(
        displayName: displayName,
        avatarUrl: avatarUrl,
      );
      return Right(user);
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = data is Map
          ? data['message']?.toString() ?? 'Cập nhật hồ sơ thất bại.'
          : 'Cập nhật hồ sơ thất bại.';
      return Left(message);
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }
}
