import 'package:soundtilo/domain/entities/auth_tokens.dart';

class AuthResponseModel {
  final String userId;
  final String username;
  final String email;
  final String? displayName;
  final String? avatarUrl;
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;

  const AuthResponseModel({
    required this.userId,
    required this.username,
    required this.email,
    this.displayName,
    this.avatarUrl,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      userId: json['userId']?.toString() ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'],
      avatarUrl: json['avatarUrl'],
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'])
          : DateTime.now().add(const Duration(hours: 2)),
    );
  }

  AuthTokens toTokens() {
    return AuthTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
    );
  }
}
