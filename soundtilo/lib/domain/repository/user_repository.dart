import 'package:dartz/dartz.dart';
import 'package:soundtilo/domain/entities/user_entity.dart';

abstract class UserRepository {
  Future<Either<String, UserEntity>> getProfile();
  Future<Either<String, UserEntity>> updateProfile({String? displayName, String? avatarUrl});
}
