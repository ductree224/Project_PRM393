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

/// Dispatched by ProfilePage on init to fetch the latest profile from the API
/// and sync the subscription tier into AuthBloc state + SharedPreferences.
class AuthProfileRefreshRequested extends AuthEvent {}
