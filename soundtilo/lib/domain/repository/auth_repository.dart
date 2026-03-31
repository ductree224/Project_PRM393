import 'package:dartz/dartz.dart';
import 'package:soundtilo/domain/entities/user_entity.dart';
import 'package:soundtilo/domain/entities/auth_tokens.dart';

abstract class AuthRepository {
  Future<Either<String, (UserEntity, AuthTokens)>> register({
    required String username,
    required String email,
    required String password,
    String? displayName,
  });

  Future<Either<String, (UserEntity, AuthTokens)>> login({
    required String usernameOrEmail,
    required String password,
  });

  Future<Either<String, (UserEntity, AuthTokens)>> googleLogin();

  Future<Either<String, AuthTokens>> refreshToken(String refreshToken);

  Future<Either<String, String>> forgotPassword(String email);

  Future<Either<String, String>> resetPassword({
    required String token,
    required String newPassword,
  });

  Future<void> logout();

  Future<bool> isLoggedIn();

  Future<String?> getAccessToken();

  Future<String?> getRefreshToken();

  Future<Either<String, void>> updateProfile({
    required String displayName,
    String? avatarUrl,
  });

  Future<Either<String, void>> changePassword({
    required String oldPassword,
    required String newPassword,
  });
}
