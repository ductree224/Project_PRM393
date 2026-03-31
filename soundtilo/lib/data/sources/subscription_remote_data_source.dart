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
}
