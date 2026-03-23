import 'package:dartz/dartz.dart';
import 'package:soundtilo/domain/entities/track_entity.dart';

abstract class TrackRepository {
  Future<Either<String, List<TrackEntity>>> search(
    String query, {
    String? source,
    int limit = 20,
    int offset = 0,
    bool cacheOnly = false,
    bool fallbackExternal = true,
  });
  Future<Either<String, List<TrackEntity>>> getTrending({String? genre, String? time, int limit = 20, int offset = 0});
  Future<Either<String, TrackEntity>> getTrack(String externalId, {String source = 'audius'});
  Future<Either<String, String>> getStreamUrl(String trackId);
}
