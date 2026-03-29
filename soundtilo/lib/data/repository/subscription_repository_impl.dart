import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:soundtilo/data/sources/subscription_remote_data_source.dart';
import 'package:soundtilo/domain/entities/subscription_plan_entity.dart';
import 'package:soundtilo/domain/repository/subscription_repository.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionRemoteDataSource _dataSource;

  SubscriptionRepositoryImpl(this._dataSource);

  @override
  Future<Either<String, List<SubscriptionPlanEntity>>> getPlans() async {
    try {
      final maps = await _dataSource.getPlans();
      final plans = maps
          .map(
            (json) => SubscriptionPlanEntity(
              id: json['id']?.toString() ?? '',
              name: json['name']?.toString() ?? '',
              price: (json['price'] as num?)?.toDouble() ?? 0.0,
              currency: (json['currency'] ?? 'vnd').toString(),
              interval: (json['interval'] ?? 'free').toString(),
              monthlyEquivalent:
                  (json['monthlyEquivalent'] as num?)?.toDouble(),
            ),
          )
          .toList();
      return Right(plans);
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = data is Map
          ? data['message']?.toString() ?? 'Không thể tải gói dịch vụ.'
          : 'Không thể tải gói dịch vụ.';
      return Left(message);
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }
}
