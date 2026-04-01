import 'package:dartz/dartz.dart';
import 'package:soundtilo/domain/entities/subscription_plan_entity.dart';

abstract class SubscriptionRepository {
  Future<Either<String, List<SubscriptionPlanEntity>>> getPlans();

  /// Creates a VNPay payment URL for the given plan ID.
  /// Returns (paymentUrl, txnRef).
  Future<Either<String, ({String paymentUrl, String txnRef})>> createPaymentUrl(
      String planId);

  /// Gets the current user's subscription status.
  Future<Either<String, SubscriptionStatusEntity>> getSubscriptionStatus();

  /// Soft-cancels the user's active subscription.
  Future<Either<String, void>> cancelSubscription();
}

class SubscriptionStatusEntity {
  final String subscriptionTier;
  final DateTime? premiumExpiresAt;
  final bool isPremium;
  final String? planName;
  final String? planInterval;
  final DateTime? currentPeriodEnd;
  final bool isCancelled;

  const SubscriptionStatusEntity({
    required this.subscriptionTier,
    this.premiumExpiresAt,
    required this.isPremium,
    this.planName,
    this.planInterval,
    this.currentPeriodEnd,
    this.isCancelled = false,
  });
}
