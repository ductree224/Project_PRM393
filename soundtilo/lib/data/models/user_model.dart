import 'package:soundtilo/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.username,
    required super.email,
    super.displayName,
    super.avatarUrl,
    super.role,
    super.isBanned,
    super.bannedReason,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['userId']?.toString() ?? json['id']?.toString() ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'],
      avatarUrl: json['avatarUrl'],
      role: json['role']?.toString(), // Lấy role từ API
      isBanned: json['isBanned'] == true,
      bannedReason: json['bannedReason']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'role': role,
      'isBanned': isBanned,
      'bannedReason': bannedReason,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
