import 'package:dartz/dartz.dart';
import 'package:soundtilo/domain/entities/subscription_plan_entity.dart';
import 'package:soundtilo/domain/entities/user_entity.dart';
import 'package:soundtilo/domain/repository/subscription_repository.dart';
import 'package:soundtilo/domain/repository/user_repository.dart';

/// Fetches all active subscription plans from the public API endpoint.
/// No authentication required.
class GetSubscriptionPlansUseCase {
  final SubscriptionRepository _repository;

  GetSubscriptionPlansUseCase(this._repository);

  Future<Either<String, List<SubscriptionPlanEntity>>> call() {
    return _repository.getPlans();
  }
}

/// Fetches the current user's full profile including subscription tier.
/// Used by AuthBloc.AuthProfileRefreshRequested to sync subscription status.
class GetProfileUseCase {
  final UserRepository _repository;

  GetProfileUseCase(this._repository);

  Future<Either<String, UserEntity>> call() {
    return _repository.getProfile();
  }
}

/// Updates the current user's profile with the provided optional fields.
class UpdateProfileUseCase {
  final UserRepository _repository;

  UpdateProfileUseCase(this._repository);

  Future<Either<String, UserEntity>> call({
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
  }) {
    return _repository.updateProfile(
      displayName: displayName,
      avatarUrl: avatarUrl,
      bio: bio,
      birthday: birthday,
      gender: gender,
      pronouns: pronouns,
      isProfilePublic: isProfilePublic,
      statusMessage: statusMessage,
      allowComments: allowComments,
      allowMessages: allowMessages,
      followerPrivacyMode: followerPrivacyMode,
    );
  }
}

/// Uploads an avatar image file and returns the hosted URL.
class UploadAvatarUseCase {
  final UserRepository _repository;

  UploadAvatarUseCase(this._repository);

  Future<Either<String, String>> call(Object file) {
    return _repository.uploadAvatar(file);
  }
}
