import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soundtilo/domain/entities/user_entity.dart';
import 'package:soundtilo/domain/usecases/auth_usecases.dart';
import 'package:soundtilo/presentation/auth/bloc/auth_event.dart';
import 'package:soundtilo/presentation/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignUpUseCase _signUpUseCase;
  final SignInUseCase _signInUseCase;
  final IsLoggedInUseCase _isLoggedInUseCase;
  final LogoutUseCase _logoutUseCase;
  final GoogleSignInUseCase _googleSignInUseCase;
  final ForgotPasswordUseCase _forgotPasswordUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;
  final SharedPreferences _prefs;
  static const _rememberMeKey = 'remember_me';
  static const _rememberedEmailKey = 'remembered_email';

  AuthBloc({
    required SignUpUseCase signUpUseCase,
    required SignInUseCase signInUseCase,
    required IsLoggedInUseCase isLoggedInUseCase,
    required LogoutUseCase logoutUseCase,
    required GoogleSignInUseCase googleSignInUseCase,
    required ForgotPasswordUseCase forgotPasswordUseCase,
    required ResetPasswordUseCase resetPasswordUseCase,
    required SharedPreferences prefs,
  }) : _signUpUseCase = signUpUseCase,
       _signInUseCase = signInUseCase,
       _isLoggedInUseCase = isLoggedInUseCase,
       _logoutUseCase = logoutUseCase,
       _googleSignInUseCase = googleSignInUseCase,
       _forgotPasswordUseCase = forgotPasswordUseCase,
       _resetPasswordUseCase = resetPasswordUseCase,
       _prefs = prefs,
       super(AuthInitial()) {
    on<AuthCheckStatus>(_onCheckStatus);
    on<AuthSignUpRequested>(_onSignUp);
    on<AuthSignInRequested>(_onSignIn);
    on<AuthGoogleSignInRequested>(_onGoogleSignIn);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthForgotPasswordRequested>(_onForgotPassword);
    on<AuthResetPasswordRequested>(_onResetPassword);
  }

  Future<void> _onCheckStatus(
    AuthCheckStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final isLoggedIn = await _isLoggedInUseCase();
    if (isLoggedIn) {
      final user = UserEntity(
        id: _prefs.getString('user_id') ?? '',
        username: _prefs.getString('username') ?? '',
        email: _prefs.getString('email') ?? '',
        displayName: _prefs.getString('display_name'),
        avatarUrl: _prefs.getString('avatar_url'),
        createdAt: DateTime.now(),
      );
      emit(AuthAuthenticated(user));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onSignUp(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _signUpUseCase(
      username: event.username,
      email: event.email,
      password: event.password,
      displayName: event.displayName,
    );
    result.fold(
      (error) => emit(AuthError(error)),
      (data) => emit(AuthAuthenticated(data.$1)),
    );
  }

  Future<void> _onSignIn(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _signInUseCase(
      usernameOrEmail: event.usernameOrEmail,
      password: event.password,
    );
    await result.fold((error) async => emit(AuthError(error)), (data) async {
      await _persistRememberMe(
        rememberMe: event.rememberMe,
        email: event.usernameOrEmail,
      );
      emit(AuthAuthenticated(data.$1));
    });
  }

  Future<void> _onGoogleSignIn(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _googleSignInUseCase();
    result.fold(
      (error) => emit(AuthError(error)),
      (data) => emit(AuthAuthenticated(data.$1)),
    );
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _logoutUseCase();
    emit(AuthUnauthenticated());
  }

  Future<void> _onForgotPassword(
    AuthForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _forgotPasswordUseCase(event.email);
    result.fold(
      (error) => emit(AuthError(error)),
      (token) => emit(AuthForgotPasswordSuccess(token)),
    );
  }

  Future<void> _onResetPassword(
    AuthResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _resetPasswordUseCase(
      token: event.token,
      newPassword: event.newPassword,
    );
    result.fold(
      (error) => emit(AuthError(error)),
      (message) => emit(AuthResetPasswordSuccess(message)),
    );
  }

  Future<void> _persistRememberMe({
    required bool rememberMe,
    required String email,
  }) async {
    await _prefs.setBool(_rememberMeKey, rememberMe);
    if (rememberMe) {
      await _prefs.setString(_rememberedEmailKey, email);
      return;
    }
    await _prefs.remove(_rememberedEmailKey);
  }
}
