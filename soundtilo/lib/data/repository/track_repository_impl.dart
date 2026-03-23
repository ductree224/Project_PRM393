import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:soundtilo/data/sources/track_remote_data_source.dart';
import 'package:soundtilo/domain/entities/track_entity.dart';
import 'package:soundtilo/domain/repository/track_repository.dart';

class TrackRepositoryImpl implements TrackRepository {
  final TrackRemoteDataSource _remoteDataSource;

  TrackRepositoryImpl(this._remoteDataSource);

  String _resolveDioErrorMessage(dynamic responseData, String fallback) {
    if (responseData is Map<String, dynamic>) {
      final message = responseData['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
      return fallback;
    }

    if (responseData is String && responseData.trim().isNotEmpty) {
      return responseData;
    }

    return fallback;
  }

  @override
  Future<Either<String, List<TrackEntity>>> search(
    String query, {
    String? source,
    int limit = 20,
    int offset = 0,
    bool cacheOnly = false,
    bool fallbackExternal = true,
  }) async {
    try {
      final tracks = await _remoteDataSource.search(
        query,
        source: source,
        limit: limit,
        offset: offset,
        cacheOnly: cacheOnly,
        fallbackExternal: fallbackExternal,
      );
      return Right(tracks);
    } on DioException catch (e) {
      return Left(
        _resolveDioErrorMessage(e.response?.data, 'Tìm kiếm thất bại.'),
      );
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }

  @override
  Future<Either<String, List<TrackEntity>>> getTrending({
    String? genre,
    String? time,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final tracks = await _remoteDataSource.getTrending(
        genre: genre,
        time: time,
        limit: limit,
        offset: offset,
      );
      return Right(tracks);
    } on DioException catch (e) {
      return Left(
        _resolveDioErrorMessage(e.response?.data, 'Không thể tải trending.'),
      );
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }

  @override
  Future<Either<String, TrackEntity>> getTrack(
    String externalId, {
    String source = 'audius',
  }) async {
    try {
      final track = await _remoteDataSource.getTrack(
        externalId,
        source: source,
      );
      return Right(track);
    } on DioException catch (e) {
      return Left(
        _resolveDioErrorMessage(e.response?.data, 'Không tìm thấy bài hát.'),
      );
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }

  @override
  Future<Either<String, String>> getStreamUrl(String trackId) async {
    try {
      final url = await _remoteDataSource.getStreamUrl(trackId);
      return Right(url);
    } on DioException catch (e) {
      return Left(
        _resolveDioErrorMessage(
          e.response?.data,
          'Không thể lấy link phát nhạc.',
        ),
      );
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }
}
