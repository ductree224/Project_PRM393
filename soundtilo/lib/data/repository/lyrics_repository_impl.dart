import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:soundtilo/data/sources/lyrics_remote_data_source.dart';
import 'package:soundtilo/domain/repository/lyrics_repository.dart';

class LyricsRepositoryImpl implements LyricsRepository {
  final LyricsRemoteDataSource _remoteDataSource;

  LyricsRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<String, String?>> getLyrics({required String artist, required String title}) async {
    try {
      final lyrics = await _remoteDataSource.getLyrics(artist: artist, title: title);
      return Right(lyrics);
    } on DioException catch (e) {
      return Left((e.response?.data is Map ? e.response?.data['message'] : null) ?? 'Không thể tải lời bài hát.');
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }
}
