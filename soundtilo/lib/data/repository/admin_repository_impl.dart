import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:soundtilo/data/models/admin_user_model.dart';
import 'package:soundtilo/data/sources/admin_remote_data_source.dart';
import 'package:soundtilo/domain/entities/admin_user_entity.dart';
import 'package:soundtilo/domain/repository/admin_repository.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource _remoteDataSource;

  AdminRepositoryImpl(this._remoteDataSource);

  String _extractDioErrorMessage(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map) {
      final dynamic message = data['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    }
    if (data is String && data.trim().isNotEmpty) {
      return data;
    }
    return fallback;
  }

  @override
  Future<Either<String, AdminUserListEntity>> getUsers({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? role,
    bool? isBanned,
  }) async {
    try {
      final data = await _remoteDataSource.getUsers(
        page: page,
        pageSize: pageSize,
        search: search,
        role: role,
        isBanned: isBanned,
      );

      final users =
          (data['users'] as List?)
              ?.map(
                (e) => AdminUserModel.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList() ??
          const <AdminUserModel>[];

      return Right(
        AdminUserListEntity(
          users: users,
          total: (data['total'] as num?)?.toInt() ?? users.length,
          page: (data['page'] as num?)?.toInt() ?? page,
          pageSize: (data['pageSize'] as num?)?.toInt() ?? pageSize,
          totalPages: (data['totalPages'] as num?)?.toInt() ?? 1,
        ),
      );
    } on DioException catch (e) {
      return Left(_extractDioErrorMessage(e, 'Không thể tải danh sách user.'));
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }

  @override
  Future<Either<String, void>> banUser(String userId, {String? reason}) async {
    try {
      await _remoteDataSource.banUser(userId, reason: reason);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_extractDioErrorMessage(e, 'Không thể khóa user.'));
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }

  @override
  Future<Either<String, void>> unbanUser(String userId) async {
    try {
      await _remoteDataSource.unbanUser(userId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_extractDioErrorMessage(e, 'Không thể mở khóa user.'));
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }

  @override
  Future<Either<String, void>> changeUserRole(
    String userId,
    String role,
  ) async {
    try {
      await _remoteDataSource.changeUserRole(userId, role);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_extractDioErrorMessage(e, 'Không thể cập nhật role user.'));
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }

  @override
  Future<Either<String, void>> deleteUser(String userId) async {
    try {
      await _remoteDataSource.deleteUser(userId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_extractDioErrorMessage(e, 'Không thể xóa user.'));
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }

  @override
  Future<Either<String, AdminUserHistoryListEntity>> getUserHistory(
    String userId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final data = await _remoteDataSource.getUserHistory(
        userId,
        page: page,
        pageSize: pageSize,
      );

      final history =
          (data['history'] as List?)
              ?.map(
                (e) => AdminUserHistoryItemModel.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList() ??
          const <AdminUserHistoryItemModel>[];

      return Right(
        AdminUserHistoryListEntity(
          history: history,
          total: (data['total'] as num?)?.toInt() ?? history.length,
          page: (data['page'] as num?)?.toInt() ?? page,
          pageSize: (data['pageSize'] as num?)?.toInt() ?? pageSize,
          totalPages: (data['totalPages'] as num?)?.toInt() ?? 1,
        ),
      );
    } on DioException catch (e) {
      return Left(_extractDioErrorMessage(e, 'Không thể tải lịch sử user.'));
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }

  @override
  Future<Either<String, AdminUserFavoriteListEntity>> getUserFavorites(
    String userId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final data = await _remoteDataSource.getUserFavorites(
        userId,
        page: page,
        pageSize: pageSize,
      );

      final favorites =
          (data['favorites'] as List?)
              ?.map(
                (e) => AdminUserFavoriteItemModel.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList() ??
          const <AdminUserFavoriteItemModel>[];

      return Right(
        AdminUserFavoriteListEntity(
          favorites: favorites,
          total: (data['total'] as num?)?.toInt() ?? favorites.length,
          page: (data['page'] as num?)?.toInt() ?? page,
          pageSize: (data['pageSize'] as num?)?.toInt() ?? pageSize,
          totalPages: (data['totalPages'] as num?)?.toInt() ?? 1,
        ),
      );
    } on DioException catch (e) {
      return Left(
        _extractDioErrorMessage(e, 'Không thể tải danh sách yêu thích user.'),
      );
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }

  @override
  Future<Either<String, AdminUserPlaylistListEntity>> getUserPlaylists(
    String userId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final data = await _remoteDataSource.getUserPlaylists(
        userId,
        page: page,
        pageSize: pageSize,
      );

      final playlists =
          (data['playlists'] as List?)
              ?.map(
                (e) => AdminUserPlaylistItemModel.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList() ??
          const <AdminUserPlaylistItemModel>[];

      return Right(
        AdminUserPlaylistListEntity(
          playlists: playlists,
          total: (data['total'] as num?)?.toInt() ?? playlists.length,
          page: (data['page'] as num?)?.toInt() ?? page,
          pageSize: (data['pageSize'] as num?)?.toInt() ?? pageSize,
          totalPages: (data['totalPages'] as num?)?.toInt() ?? 1,
        ),
      );
    } on DioException catch (e) {
      return Left(_extractDioErrorMessage(e, 'Không thể tải playlists user.'));
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }
}
