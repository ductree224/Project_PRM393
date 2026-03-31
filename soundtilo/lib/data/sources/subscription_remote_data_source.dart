import 'package:dio/dio.dart';
import 'package:soundtilo/core/constants/api_urls.dart';

class SubscriptionRemoteDataSource {
  final Dio _dio;

  SubscriptionRemoteDataSource(this._dio);

  Future<List<Map<String, dynamic>>> getPlans() async {
    final response = await _dio.get(ApiUrls.subscriptionPlans);
    final data = response.data as Map<String, dynamic>;
    return (data['plans'] as List).cast<Map<String, dynamic>>();
  }

  /// Creates a VNPay payment URL for the given plan.
  Future<Map<String, dynamic>> createPaymentUrl(String planId) async {
    final response = await _dio.post(
      ApiUrls.createPaymentUrl,
      data: {'planId': planId},
    );
    return response.data as Map<String, dynamic>;
  }

  /// Gets current user's subscription status.
  Future<Map<String, dynamic>> getSubscriptionStatus() async {
    final response = await _dio.get(ApiUrls.subscriptionStatus);
    return response.data as Map<String, dynamic>;
  }
}
