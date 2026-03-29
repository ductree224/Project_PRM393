import 'package:dartz/dartz.dart';
import 'package:soundtilo/domain/entities/subscription_plan_entity.dart';

abstract class SubscriptionRepository {
  Future<Either<String, List<SubscriptionPlanEntity>>> getPlans();
}
