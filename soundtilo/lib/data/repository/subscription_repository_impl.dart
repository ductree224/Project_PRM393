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

  @override
  Future<Either<String, ({String paymentUrl, String txnRef})>>
      createPaymentUrl(String planId) async {
    try {
      final data = await _dataSource.createPaymentUrl(planId);
      final paymentUrl = data['paymentUrl']?.toString() ?? '';
      final txnRef = data['txnRef']?.toString() ?? '';
      return Right((paymentUrl: paymentUrl, txnRef: txnRef));
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = data is Map
          ? data['message']?.toString() ?? 'Không thể tạo liên kết thanh toán.'
          : 'Không thể tạo liên kết thanh toán.';
      return Left(message);
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }

  @override
  Future<Either<String, void>> cancelSubscription() async {
    try {
      await _dataSource.cancelSubscription();
      return const Right(null);
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = data is Map
          ? data['message']?.toString() ?? 'Không thể hủy đăng ký.'
          : 'Không thể hủy đăng ký.';
      return Left(message);
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }

  @override
  Future<Either<String, SubscriptionStatusEntity>>
      getSubscriptionStatus() async {
    try {
      final data = await _dataSource.getSubscriptionStatus();
      final status = SubscriptionStatusEntity(
        subscriptionTier: data['subscriptionTier']?.toString() ?? 'free',
        premiumExpiresAt: data['premiumExpiresAt'] != null
            ? DateTime.tryParse(data['premiumExpiresAt'].toString())
            : null,
        isPremium: data['isPremium'] == true,
        planName: data['planName']?.toString(),
        planInterval: data['planInterval']?.toString(),
        currentPeriodEnd: data['currentPeriodEnd'] != null
            ? DateTime.tryParse(data['currentPeriodEnd'].toString())
            : null,
      );
      return Right(status);
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = data is Map
          ? data['message']?.toString() ?? 'Không thể tải trạng thái đăng ký.'
          : 'Không thể tải trạng thái đăng ký.';
      return Left(message);
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }
}
