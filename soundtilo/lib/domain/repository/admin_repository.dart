import 'package:dartz/dartz.dart';
import 'package:soundtilo/domain/entities/admin_user_entity.dart';

abstract class AdminRepository {
  Future<Either<String, AdminUserListEntity>> getUsers({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? role,
    bool? isBanned,
  });

  Future<Either<String, void>> banUser(String userId, {String? reason});

  Future<Either<String, void>> unbanUser(String userId);

  Future<Either<String, void>> changeUserRole(String userId, String role);

  Future<Either<String, void>> deleteUser(String userId);

  Future<Either<String, AdminUserHistoryListEntity>> getUserHistory(
    String userId, {
    int page = 1,
    int pageSize = 20,
  });

  Future<Either<String, AdminUserFavoriteListEntity>> getUserFavorites(
    String userId, {
    int page = 1,
    int pageSize = 20,
  });

  Future<Either<String, AdminUserPlaylistListEntity>> getUserPlaylists(
    String userId, {
    int page = 1,
    int pageSize = 20,
  });
}
