import 'package:dartz/dartz.dart';
import '../../data/models/track_admin_model.dart';

abstract class TrackAdminRepository {
  Future<Either<String, List<TrackAdminModel>>> getTracks({
    String? status,
    String? query,
    int limit = 50,
    int offset = 0,
  });

  Future<Either<String, void>> updateTrackStatus({
    required List<String> externalIds,
    required String status,
  });
}
