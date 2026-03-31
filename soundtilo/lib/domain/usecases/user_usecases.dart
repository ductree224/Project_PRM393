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

/// Creates a VNPay payment URL for the selected plan.
class CreatePaymentUrlUseCase {
  final SubscriptionRepository _repository;

  CreatePaymentUrlUseCase(this._repository);

  Future<Either<String, ({String paymentUrl, String txnRef})>> call(
      String planId) {
    return _repository.createPaymentUrl(planId);
  }
}

/// Gets the current user's subscription status.
class GetSubscriptionStatusUseCase {
  final SubscriptionRepository _repository;

  GetSubscriptionStatusUseCase(this._repository);

  Future<Either<String, SubscriptionStatusEntity>> call() {
    return _repository.getSubscriptionStatus();
  }
}
