import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soundtilo/data/models/auth_response_model.dart';
import 'package:soundtilo/data/models/user_model.dart';
import 'package:soundtilo/data/sources/auth_remote_data_source.dart';
import 'package:soundtilo/domain/entities/auth_tokens.dart';
import 'package:soundtilo/domain/entities/user_entity.dart';
import 'package:soundtilo/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SharedPreferences _prefs;

  AuthRepositoryImpl(this._remoteDataSource, this._prefs);

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _expiresAtKey = 'expires_at';
  static const _userIdKey = 'user_id';
  static const _usernameKey = 'username';
  static const _emailKey = 'email';
  static const _displayNameKey = 'display_name';
  static const _avatarUrlKey = 'avatar_url';

  @override
  Future<Either<String, (UserEntity, AuthTokens)>> register({
    required String username,
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final response = await _remoteDataSource.register(
        username: username,
        email: email,
        password: password,
        displayName: displayName,
      );
      await _saveTokens(response);
      final user = UserModel(
        id: response.userId,
        username: response.username,
        email: response.email,
        displayName: response.displayName,
        avatarUrl: response.avatarUrl,
        createdAt: DateTime.now(),
      );
      return Right((user, response.toTokens()));
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? 'Đăng ký thất bại. Vui lòng thử lại.';
      return Left(message);
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }

  @override
  Future<Either<String, (UserEntity, AuthTokens)>> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    try {
      final response = await _remoteDataSource.login(
        usernameOrEmail: usernameOrEmail,
        password: password,
      );
      await _saveTokens(response);
      final user = UserModel(
        id: response.userId,
        username: response.username,
        email: response.email,
        displayName: response.displayName,
        avatarUrl: response.avatarUrl,
        createdAt: DateTime.now(),
      );
      return Right((user, response.toTokens()));
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ??
          'Đăng nhập thất bại. Vui lòng thử lại.';
      return Left(message);
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }

  @override
  Future<Either<String, (UserEntity, AuthTokens)>> googleLogin() async {
    try {
      final googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        serverClientId: dotenv.env['GOOGLE_SERVER_CLIENT_ID'],
      );
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return const Left('Đã hủy đăng nhập Google.');
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) {
        return const Left('Không lấy được token từ Google.');
      }

      final response = await _remoteDataSource.googleLogin(idToken);
      await _saveTokens(response);
      final user = UserModel(
        id: response.userId,
        username: response.username,
        email: response.email,
        displayName: response.displayName,
        avatarUrl: response.avatarUrl,
        createdAt: DateTime.now(),
      );
      return Right((user, response.toTokens()));
    } on DioException catch (e) {
      final data = e.response?.data;
      String message;
      if (data is Map) {
        message = data['message']?.toString() ?? data.toString();
      } else if (data != null) {
        message = data.toString();
      } else {
        message = 'Lỗi kết nối: ${e.message ?? e.type.name}';
      }
      return Left(message);
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }

  @override
  Future<Either<String, AuthTokens>> refreshToken(String refreshToken) async {
    try {
      final response = await _remoteDataSource.refreshToken(refreshToken);
      await _saveTokens(response);
      return Right(response.toTokens());
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? 'Phiên đăng nhập đã hết hạn.';
      return Left(message);
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }

  @override
  Future<Either<String, String>> forgotPassword(String email) async {
    try {
      final token = await _remoteDataSource.forgotPassword(email);
      return Right(token);
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? 'Yêu cầu đặt lại mật khẩu thất bại.';
      return Left(message);
    } on FormatException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }

  @override
  Future<Either<String, String>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final message = await _remoteDataSource.resetPassword(
        token: token,
        newPassword: newPassword,
      );
      return Right(message);
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? 'Đặt lại mật khẩu thất bại.';
      return Left(message);
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }

  @override
  Future<void> logout() async {
    await _prefs.remove(_accessTokenKey);
    await _prefs.remove(_refreshTokenKey);
    await _prefs.remove(_expiresAtKey);
    await _prefs.remove(_userIdKey);
    await _prefs.remove(_usernameKey);
    await _prefs.remove(_emailKey);
    await _prefs.remove(_displayNameKey);
    await _prefs.remove(_avatarUrlKey);
  }

  @override
  Future<bool> isLoggedIn() async {
    // Chỉ kiểm tra local SharedPreferences — KHÔNG gọi network.
    // Refresh token sẽ xảy ra lazy khi API calls trả về 401.
    final token = _prefs.getString(_accessTokenKey);
    final refreshTokenValue = _prefs.getString(_refreshTokenKey);

    // Cần có ít nhất refresh token để coi là "đăng nhập"
    if (token == null && refreshTokenValue == null) return false;
    if (refreshTokenValue == null) return false;

    // Nếu có access token và chưa hết hạn → đã đăng nhập
    if (token != null) {
      final expiresAt = _prefs.getString(_expiresAtKey);
      if (expiresAt != null) {
        final expires = DateTime.tryParse(expiresAt);
        if (expires != null && DateTime.now().isBefore(expires)) {
          return true;
        }
      }
    }

    // Access token hết hạn nhưng còn refresh token
    // → vẫn coi là đăng nhập, ApiClient interceptor sẽ tự refresh khi cần
    return true;
  }

  @override
  Future<String?> getAccessToken() async {
    return _prefs.getString(_accessTokenKey);
  }

  @override
  Future<String?> getRefreshToken() async {
    return _prefs.getString(_refreshTokenKey);
  }

  Future<void> _saveTokens(AuthResponseModel response) async {
    await _prefs.setString(_accessTokenKey, response.accessToken);
    await _prefs.setString(_refreshTokenKey, response.refreshToken);
    await _prefs.setString(_expiresAtKey, response.expiresAt.toIso8601String());
    await _prefs.setString(_userIdKey, response.userId);
    await _prefs.setString(_usernameKey, response.username);
    await _prefs.setString(_emailKey, response.email);
    if (response.displayName != null) {
      await _prefs.setString(_displayNameKey, response.displayName!);
    }
    if (response.avatarUrl != null) {
      await _prefs.setString(_avatarUrlKey, response.avatarUrl!);
    }
  }
}
