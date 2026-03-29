import 'package:dartz/dartz.dart';
import 'package:soundtilo/domain/entities/user_entity.dart';

abstract class UserRepository {
  Future<Either<String, UserEntity>> getProfile();
  Future<Either<String, UserEntity>> updateProfile({
    String? displayName,
    String? avatarUrl,
    String? bio,
    DateTime? birthday,
    String? gender,
    String? pronouns,
    bool? isProfilePublic,
    String? statusMessage,
    bool? allowComments,
    bool? allowMessages,
    String? followerPrivacyMode,
  });

  /// `file` can be a local file path (`String`) or raw bytes (`Uint8List`) for web.
  Future<Either<String, String>> uploadAvatar(Object file);
}
