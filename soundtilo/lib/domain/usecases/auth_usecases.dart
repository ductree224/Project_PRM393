import 'package:dartz/dartz.dart';
import 'package:soundtilo/domain/entities/auth_tokens.dart';
import 'package:soundtilo/domain/entities/user_entity.dart';
import 'package:soundtilo/domain/repository/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<Either<String, (UserEntity, AuthTokens)>> call({
    required String username,
    required String email,
    required String password,
    String? displayName,
  }) {
    return repository.register(
      username: username,
      email: email,
      password: password,
      displayName: displayName,
    );
  }
}

class SignInUseCase {
  final AuthRepository repository;

  SignInUseCase(this.repository);

  Future<Either<String, (UserEntity, AuthTokens)>> call({
    required String usernameOrEmail,
    required String password,
  }) {
    return repository.login(
      usernameOrEmail: usernameOrEmail,
      password: password,
    );
  }
}

class IsLoggedInUseCase {
  final AuthRepository repository;

  IsLoggedInUseCase(this.repository);

  Future<bool> call() => repository.isLoggedIn();
}

class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<void> call() => repository.logout();
}

class GoogleSignInUseCase {
  final AuthRepository repository;

  GoogleSignInUseCase(this.repository);

  Future<Either<String, (UserEntity, AuthTokens)>> call() {
    return repository.googleLogin();
  }
}

class ForgotPasswordUseCase {
  final AuthRepository repository;

  ForgotPasswordUseCase(this.repository);

  Future<Either<String, String>> call(String email) {
    return repository.forgotPassword(email);
  }
}

class ResetPasswordUseCase {
  final AuthRepository repository;

  ResetPasswordUseCase(this.repository);

  Future<Either<String, String>> call({
    required String token,
    required String newPassword,
  }) {
    return repository.resetPassword(token: token, newPassword: newPassword);
  }
}
class UpdateProfileUseCase {
  final AuthRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<Either<String, void>> call({
    required String displayName,
    String? avatarUrl,
  }) {
    return repository.updateProfile(
      displayName: displayName,
      avatarUrl: avatarUrl,
    );
  }
}

class ChangePasswordUseCase {
  final AuthRepository repository;

  ChangePasswordUseCase(this.repository);

  Future<Either<String, void>> call({
    required String oldPassword,
    required String newPassword,
  }) {
    return repository.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
  }
}
