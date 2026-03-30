import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthSignUpRequested extends AuthEvent {
  final String username;
  final String email;
  final String password;
  final String? displayName;

  const AuthSignUpRequested({
    required this.username,
    required this.email,
    required this.password,
    this.displayName,
  });

  @override
  List<Object?> get props => [username, email, password, displayName];
}

class AuthSignInRequested extends AuthEvent {
  final String usernameOrEmail;
  final String password;
  final bool rememberMe;

  const AuthSignInRequested({
    required this.usernameOrEmail,
    required this.password,
    required this.rememberMe,
  });

  @override
  List<Object?> get props => [usernameOrEmail, password, rememberMe];
}

class AuthGoogleSignInRequested extends AuthEvent {}

class AuthLogoutRequested extends AuthEvent {}

class AuthCheckStatus extends AuthEvent {}

class AuthForgotPasswordRequested extends AuthEvent {
  final String email;

  const AuthForgotPasswordRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

class AuthResetPasswordRequested extends AuthEvent {
  final String token;
  final String newPassword;

  const AuthResetPasswordRequested({
    required this.token,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [token, newPassword];
}
// Sự kiện yêu cầu cập nhật thông tin cá nhân (Tên, Avatar)
class AuthUpdateProfileRequested extends AuthEvent {
  final String displayName;
  final String? avatarUrl;

  AuthUpdateProfileRequested({required this.displayName, this.avatarUrl});
}

// Sự kiện yêu cầu đổi mật khẩu
class AuthChangePasswordRequested extends AuthEvent {
  final String oldPassword;
  final String newPassword;

  AuthChangePasswordRequested({
    required this.oldPassword,
    required this.newPassword,
  });
}