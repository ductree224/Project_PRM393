import 'package:dartz/dartz.dart';
import 'package:soundtilo/domain/entities/track_entity.dart';
import 'package:soundtilo/domain/repository/track_repository.dart';

class SearchTracksUseCase {
  final TrackRepository repository;

  SearchTracksUseCase(this.repository);

  Future<Either<String, List<TrackEntity>>> call(
    String query, {
    String? source,
    int limit = 20,
    int offset = 0,
    bool cacheOnly = false,
    bool fallbackExternal = true,
  }) {
    return repository.search(
      query,
      source: source,
      limit: limit,
      offset: offset,
      cacheOnly: cacheOnly,
      fallbackExternal: fallbackExternal,
    );
  }
}

class GetTrendingUseCase {
  final TrackRepository repository;

  GetTrendingUseCase(this.repository);

  Future<Either<String, List<TrackEntity>>> call({String? genre, String? time, int limit = 20}) {
    return repository.getTrending(genre: genre, time: time, limit: limit);
  }
}

class GetTrackUseCase {
  final TrackRepository repository;

  GetTrackUseCase(this.repository);

  Future<Either<String, TrackEntity>> call(String externalId, {String source = 'audius'}) {
    return repository.getTrack(externalId, source: source);
  }
}

class GetStreamUrlUseCase {
  final TrackRepository repository;

  GetStreamUrlUseCase(this.repository);

  Future<Either<String, String>> call(String trackId) {
    return repository.getStreamUrl(trackId);
  }
}
