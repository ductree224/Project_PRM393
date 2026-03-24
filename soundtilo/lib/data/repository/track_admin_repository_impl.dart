import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../core/constants/api_urls.dart';
import '../../domain/repositories/track_admin_repository.dart';
import '../models/track_admin_model.dart';

class TrackAdminRepositoryImpl implements TrackAdminRepository {
  final Dio dio;

  TrackAdminRepositoryImpl(this.dio);

  @override
  Future<Either<String, List<TrackAdminModel>>> getTracks({
    String? status,
    String? query,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };
      if (status != null && status != 'All') {
        // Map status string to enum index if needed, but our backend takes enum string or int.
        // Let's assume backend handles string names like "Active", "Inactive", "Hidden".
        queryParams['status'] = status;
      }
      if (query != null && query.isNotEmpty) {
        queryParams['q'] = query;
      }

      final response = await dio.get(
        ApiUrls.adminTracks,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return Right((response.data as List)
            .map((x) => TrackAdminModel.fromJson(x))
            .toList());
      } else {
        return const Left('Failed to load admin tracks');
      }
    } on DioException catch (e) {
      return Left(e.response?.data['message'] ?? 'Error loading tracks');
    } catch (e) {
      return Left('Error: $e');
    }
  }

  @override
  Future<Either<String, void>> updateTrackStatus({
    required List<String> externalIds,
    required String status,
  }) async {
    try {
      // status string to enum value (0=Active, 1=Inactive, 2=Hidden)
      int statusValue = 0;
      if (status == 'Inactive') statusValue = 1;
      else if (status == 'Hidden') statusValue = 2;

      final response = await dio.patch(
        ApiUrls.updateAdminTrackStatus,
        data: {
          'externalIds': externalIds,
          'status': statusValue,
        },
      );

      if (response.statusCode == 204 || response.statusCode == 200) {
        return const Right(null);
      } else {
        return const Left('Failed to update track status');
      }
    } on DioException catch (e) {
      return Left(e.response?.data['message'] ?? 'Error updating track status');
    } catch (e) {
      return Left('Error: $e');
    }
  }
}
