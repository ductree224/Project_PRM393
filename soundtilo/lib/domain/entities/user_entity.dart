import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String username;
  final String email;
  final String? displayName;
  final String? avatarUrl;
  final String? role;
  final bool isBanned;
  final String? bannedReason;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.username,
    required this.email,
    this.displayName,
    this.avatarUrl,
    this.role,
    this.isBanned = false,
    this.bannedReason,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    username,
    email,
    displayName,
    avatarUrl,
    role,
    isBanned,
    bannedReason,
    createdAt,
  ];
}
