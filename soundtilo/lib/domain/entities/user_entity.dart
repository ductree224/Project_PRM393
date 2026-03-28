import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String username;
  final String email;
  final String? displayName;
  final String? avatarUrl;
  final String? role;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.username,
    required this.email,
    this.displayName,
    this.avatarUrl,
    this.role,
    required this.createdAt,
  });

  @override
<<<<<<< HEAD
  List<Object?> get props => [
    id,
    username,
    email,
    displayName,
    avatarUrl,
    createdAt,
  ];
=======
  List<Object?> get props => [id, username, email, displayName, avatarUrl, role, createdAt];
>>>>>>> quan
}
