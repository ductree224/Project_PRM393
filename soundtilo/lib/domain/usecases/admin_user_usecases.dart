import 'package:dartz/dartz.dart';
import 'package:soundtilo/domain/entities/admin_user_entity.dart';
import 'package:soundtilo/domain/repository/admin_repository.dart';

class GetAdminUsersUseCase {
  final AdminRepository repository;

  GetAdminUsersUseCase(this.repository);

  Future<Either<String, AdminUserListEntity>> call({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? role,
    bool? isBanned,
    String? subscriptionTier,
  }) {
    return repository.getUsers(
      page: page,
      pageSize: pageSize,
      search: search,
      role: role,
      isBanned: isBanned,
      subscriptionTier: subscriptionTier,
    );
  }
}

class BanAdminUserUseCase {
  final AdminRepository repository;

  BanAdminUserUseCase(this.repository);

  Future<Either<String, void>> call(String userId, {String? reason}) {
    return repository.banUser(userId, reason: reason);
  }
}

class UnbanAdminUserUseCase {
  final AdminRepository repository;

  UnbanAdminUserUseCase(this.repository);

  Future<Either<String, void>> call(String userId) {
    return repository.unbanUser(userId);
  }
}

class ChangeAdminUserRoleUseCase {
  final AdminRepository repository;

  ChangeAdminUserRoleUseCase(this.repository);

  Future<Either<String, void>> call(String userId, String role) {
    return repository.changeUserRole(userId, role);
  }
}

class DeleteAdminUserUseCase {
  final AdminRepository repository;

  DeleteAdminUserUseCase(this.repository);

  Future<Either<String, void>> call(String userId) {
    return repository.deleteUser(userId);
  }
}

class GetAdminUserHistoryUseCase {
  final AdminRepository repository;

  GetAdminUserHistoryUseCase(this.repository);

  Future<Either<String, AdminUserHistoryListEntity>> call(
    String userId, {
    int page = 1,
    int pageSize = 20,
  }) {
    return repository.getUserHistory(userId, page: page, pageSize: pageSize);
  }
}

class GetAdminUserFavoritesUseCase {
  final AdminRepository repository;

  GetAdminUserFavoritesUseCase(this.repository);

  Future<Either<String, AdminUserFavoriteListEntity>> call(
    String userId, {
    int page = 1,
    int pageSize = 20,
  }) {
    return repository.getUserFavorites(userId, page: page, pageSize: pageSize);
  }
}

class GetAdminUserPlaylistsUseCase {
  final AdminRepository repository;

  GetAdminUserPlaylistsUseCase(this.repository);

  Future<Either<String, AdminUserPlaylistListEntity>> call(
    String userId, {
    int page = 1,
    int pageSize = 20,
  }) {
    return repository.getUserPlaylists(userId, page: page, pageSize: pageSize);
  }
}

class GrantPremiumUseCase {
  final AdminRepository repository;

  GrantPremiumUseCase(this.repository);

  Future<Either<String, void>> call(
    String userId, {
    DateTime? expiresAt,
  }) {
    return repository.grantPremium(userId, expiresAt: expiresAt);
  }
}

class RevokePremiumUseCase {
  final AdminRepository repository;

  RevokePremiumUseCase(this.repository);

  Future<Either<String, void>> call(String userId) {
    return repository.revokePremium(userId);
  }
}
